#!/bin/bash

# 完整的Maven Central自动化流程
# 包括构建、签名、打包和自动上传

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PURPLE}🚀 Maven Central 完整自动化流程${NC}"
echo "======================================"

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}📁 项目根目录: $PROJECT_ROOT${NC}"

# 检查环境变量
echo -e "\n${YELLOW}🔍 检查环境变量...${NC}"

if [ -z "$CENTRAL_USERNAME" ]; then
    echo -e "${RED}❌ CENTRAL_USERNAME 环境变量未设置${NC}"
    echo "请设置: export CENTRAL_USERNAME=your_username"
    echo "或者运行: CENTRAL_USERNAME=your_username CENTRAL_PASSWORD=your_password $0"
    exit 1
fi

if [ -z "$CENTRAL_PASSWORD" ]; then
    echo -e "${RED}❌ CENTRAL_PASSWORD 环境变量未设置${NC}"
    echo "请设置: export CENTRAL_PASSWORD=your_password"
    echo "或者运行: CENTRAL_USERNAME=your_username CENTRAL_PASSWORD=your_password $0"
    exit 1
fi

echo -e "${GREEN}✅ 环境变量已设置${NC}"

# 步骤1: 构建和签名
echo -e "\n${YELLOW}🔨 步骤1: 构建和签名...${NC}"
cd "$PROJECT_ROOT"

if [ -f "scripts/build-and-sign-android.sh" ]; then
    echo "运行构建脚本..."
    ./scripts/build-and-sign-android.sh
    echo -e "${GREEN}✅ 构建和签名完成${NC}"
else
    echo -e "${RED}❌ 构建脚本未找到${NC}"
    exit 1
fi

# 步骤2: 自动上传
echo -e "\n${YELLOW}📤 步骤2: 自动上传到Maven Central...${NC}"

if [ -f "scripts/auto-upload-to-central.sh" ]; then
    echo "运行自动上传脚本..."
    ./scripts/auto-upload-to-central.sh
    echo -e "${GREEN}✅ 自动上传完成${NC}"
else
    echo -e "${RED}❌ 上传脚本未找到${NC}"
    exit 1
fi

echo -e "\n${GREEN}🎉 完整自动化流程完成！${NC}"
echo -e "${BLUE}📋 你的Android SDK已成功发布到Maven Central${NC}"
echo -e "${BLUE}🌐 查看: https://central.sonatype.com/${NC}"
echo -e "${BLUE}📦 使用: implementation 'org.very:veryoauthsdk:1.0.0'${NC}"
