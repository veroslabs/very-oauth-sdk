#!/bin/bash

# 自动上传到Maven Central的完整脚本
# 基于Sonatype Central Publishing API

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Maven Central 自动上传脚本${NC}"
echo "=================================="

# 配置变量
CENTRAL_API_BASE="https://central.sonatype.com/api/v1"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPLOAD_DIR="$PROJECT_ROOT/upload-package"
ZIP_FILE="$UPLOAD_DIR/veryoauthsdk-1.0.0.zip"

# 检查环境变量
echo -e "\n${YELLOW}🔍 检查环境变量...${NC}"

if [ -z "$CENTRAL_USERNAME" ]; then
    echo -e "${RED}❌ CENTRAL_USERNAME 环境变量未设置${NC}"
    echo "请设置: export CENTRAL_USERNAME=your_username"
    exit 1
fi

if [ -z "$CENTRAL_PASSWORD" ]; then
    echo -e "${RED}❌ CENTRAL_PASSWORD 环境变量未设置${NC}"
    echo "请设置: export CENTRAL_PASSWORD=your_password"
    exit 1
fi

echo -e "${GREEN}✅ 环境变量已设置${NC}"

# 生成认证令牌
echo -e "\n${YELLOW}🔐 生成认证令牌...${NC}"
AUTH_TOKEN=$(printf "%s:%s" "$CENTRAL_USERNAME" "$CENTRAL_PASSWORD" | base64)
echo -e "${GREEN}✅ 认证令牌已生成${NC}"

# 检查ZIP文件是否存在
echo -e "\n${YELLOW}📦 检查上传文件...${NC}"
if [ ! -f "$ZIP_FILE" ]; then
    echo -e "${RED}❌ ZIP文件不存在: $ZIP_FILE${NC}"
    echo "请先运行: ./scripts/build-and-sign-android.sh"
    exit 1
fi

ZIP_SIZE=$(du -h "$ZIP_FILE" | cut -f1)
echo -e "${GREEN}✅ 找到ZIP文件: $ZIP_FILE ($ZIP_SIZE)${NC}"

# 步骤1: 上传部署包
echo -e "\n${YELLOW}📤 步骤1: 上传部署包...${NC}"

UPLOAD_RESPONSE=$(curl -s -w "\n%{http_code}" \
    --request POST \
    --header "Authorization: Bearer $AUTH_TOKEN" \
    --form "bundle=@$ZIP_FILE" \
    --form "name=VeryOauthSDK-1.0.0" \
    --form "publishingType=AUTOMATIC" \
    "$CENTRAL_API_BASE/publisher/upload")

# 分离响应体和状态码
HTTP_CODE=$(echo "$UPLOAD_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$UPLOAD_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" -eq 201 ]; then
    DEPLOYMENT_ID="$RESPONSE_BODY"
    echo -e "${GREEN}✅ 上传成功${NC}"
    echo -e "${BLUE}📋 部署ID: $DEPLOYMENT_ID${NC}"
else
    echo -e "${RED}❌ 上传失败 (HTTP $HTTP_CODE)${NC}"
    echo "响应: $RESPONSE_BODY"
    exit 1
fi

# 步骤2: 监控部署状态
echo -e "\n${YELLOW}⏳ 步骤2: 监控部署状态...${NC}"

MAX_ATTEMPTS=30
ATTEMPT=0
SLEEP_INTERVAL=10

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    echo -e "${BLUE}📊 检查状态 (尝试 $ATTEMPT/$MAX_ATTEMPTS)...${NC}"
    
    STATUS_RESPONSE=$(curl -s -w "\n%{http_code}" \
        --request POST \
        --header "Authorization: Bearer $AUTH_TOKEN" \
        "$CENTRAL_API_BASE/publisher/status?id=$DEPLOYMENT_ID")
    
    HTTP_CODE=$(echo "$STATUS_RESPONSE" | tail -n1)
    STATUS_BODY=$(echo "$STATUS_RESPONSE" | head -n -1)
    
    if [ "$HTTP_CODE" -eq 200 ]; then
        # 解析JSON响应 (需要jq工具)
        if command -v jq &> /dev/null; then
            DEPLOYMENT_STATE=$(echo "$STATUS_BODY" | jq -r '.deploymentState')
            DEPLOYMENT_NAME=$(echo "$STATUS_BODY" | jq -r '.deploymentName')
            
            echo -e "${BLUE}📋 部署名称: $DEPLOYMENT_NAME${NC}"
            echo -e "${BLUE}📊 部署状态: $DEPLOYMENT_STATE${NC}"
            
            case "$DEPLOYMENT_STATE" in
                "PENDING")
                    echo -e "${YELLOW}⏳ 等待处理中...${NC}"
                    ;;
                "VALIDATING")
                    echo -e "${YELLOW}🔍 验证中...${NC}"
                    ;;
                "VALIDATED")
                    echo -e "${GREEN}✅ 验证通过，等待发布...${NC}"
                    ;;
                "PUBLISHING")
                    echo -e "${YELLOW}📤 发布中...${NC}"
                    ;;
                "PUBLISHED")
                    echo -e "${GREEN}🎉 发布成功！${NC}"
                    
                    # 显示包URL
                    PURLS=$(echo "$STATUS_BODY" | jq -r '.purls[]?' 2>/dev/null || echo "")
                    if [ -n "$PURLS" ]; then
                        echo -e "${BLUE}📦 包URL:${NC}"
                        echo "$PURLS" | while read -r purl; do
                            echo -e "${GREEN}  - $purl${NC}"
                        done
                    fi
                    
                    echo -e "\n${GREEN}🎯 发布完成！${NC}"
                    echo -e "${BLUE}📋 部署ID: $DEPLOYMENT_ID${NC}"
                    echo -e "${BLUE}🌐 查看: https://central.sonatype.com/${NC}"
                    exit 0
                    ;;
                "FAILED")
                    echo -e "${RED}❌ 发布失败${NC}"
                    echo "响应: $STATUS_BODY"
                    exit 1
                    ;;
                *)
                    echo -e "${YELLOW}❓ 未知状态: $DEPLOYMENT_STATE${NC}"
                    ;;
            esac
        else
            echo -e "${YELLOW}⚠️  未安装jq，无法解析JSON响应${NC}"
            echo "响应: $STATUS_BODY"
        fi
    else
        echo -e "${RED}❌ 状态检查失败 (HTTP $HTTP_CODE)${NC}"
        echo "响应: $STATUS_BODY"
    fi
    
    if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
        echo -e "${BLUE}⏳ 等待 $SLEEP_INTERVAL 秒后重试...${NC}"
        sleep $SLEEP_INTERVAL
    fi
done

echo -e "${RED}❌ 超时：部署状态检查超过 $MAX_ATTEMPTS 次尝试${NC}"
echo -e "${YELLOW}💡 请手动检查部署状态: https://central.sonatype.com/${NC}"
exit 1
