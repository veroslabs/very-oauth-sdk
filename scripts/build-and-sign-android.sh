#!/bin/bash

# Android SDK 完整构建、签名和打包脚本
# 包括编译、GPG签名、校验和生成、ZIP打包

set -e

echo "🚀 Android SDK 完整构建流程"
echo "=============================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$PROJECT_ROOT/android"
UPLOAD_DIR="$PROJECT_ROOT/upload-package"

echo -e "${BLUE}📁 项目根目录: $PROJECT_ROOT${NC}"
echo -e "${BLUE}📁 Android目录: $ANDROID_DIR${NC}"
echo -e "${BLUE}📁 上传目录: $UPLOAD_DIR${NC}"

# 检查必要工具
echo -e "\n${YELLOW}🔍 检查必要工具...${NC}"

# 检查Gradle
if [ ! -f "$ANDROID_DIR/gradlew" ]; then
    echo -e "${RED}❌ Gradle Wrapper 未找到${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Gradle Wrapper 已找到${NC}"

# 检查GPG
if ! command -v gpg &> /dev/null; then
    echo -e "${RED}❌ GPG 未安装${NC}"
    echo "请安装GPG: brew install gnupg"
    exit 1
fi
echo -e "${GREEN}✅ GPG 已安装${NC}"

# 检查GPG密钥
if ! gpg --list-secret-keys --keyid-format LONG | grep -q "sec"; then
    echo -e "${RED}❌ 没有找到GPG密钥${NC}"
    echo "请先生成GPG密钥: gpg --full-generate-key"
    exit 1
fi
echo -e "${GREEN}✅ GPG密钥已找到${NC}"

# 获取GPG密钥信息
GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format LONG | grep "sec" | head -1 | awk '{print $2}' | cut -d'/' -f2)
echo -e "${BLUE}🔑 GPG密钥ID: $GPG_KEY_ID${NC}"

# 步骤1: 清理和构建
echo -e "\n${YELLOW}🧹 步骤1: 清理和构建...${NC}"
cd "$ANDROID_DIR"

echo "清理项目..."
./gradlew clean

echo "构建项目..."
./gradlew :veryoauthsdk:build

echo "生成发布版本..."
./gradlew :veryoauthsdk:assembleRelease

echo "生成源码和文档..."
./gradlew :veryoauthsdk:sourcesJar :veryoauthsdk:javadocJar

echo "生成POM文件..."
./gradlew :veryoauthsdk:generatePomFileForReleasePublication

echo -e "${GREEN}✅ 构建完成${NC}"

# 步骤2: 准备上传目录
echo -e "\n${YELLOW}📦 步骤2: 准备上传目录...${NC}"

# 清理并创建上传目录
rm -rf "$UPLOAD_DIR"
mkdir -p "$UPLOAD_DIR/org/very/veryoauthsdk/1.0.0"

# 复制文件到正确位置
echo "复制AAR文件..."
cp "$ANDROID_DIR/veryoauthsdk/build/outputs/aar/veryoauthsdk-release.aar" \
   "$UPLOAD_DIR/org/very/veryoauthsdk/1.0.0/veryoauthsdk-1.0.0.aar"

echo "复制POM文件..."
cp "$ANDROID_DIR/veryoauthsdk/build/publications/release/pom-default.xml" \
   "$UPLOAD_DIR/org/very/veryoauthsdk/1.0.0/veryoauthsdk-1.0.0.pom"

echo "复制源码JAR..."
cp "$ANDROID_DIR/veryoauthsdk/build/libs/veryoauthsdk-sources.jar" \
   "$UPLOAD_DIR/org/very/veryoauthsdk/1.0.0/veryoauthsdk-1.0.0-sources.jar"

echo "复制文档JAR..."
cp "$ANDROID_DIR/veryoauthsdk/build/libs/veryoauthsdk-javadoc.jar" \
   "$UPLOAD_DIR/org/very/veryoauthsdk/1.0.0/veryoauthsdk-1.0.0-javadoc.jar"

echo -e "${GREEN}✅ 文件复制完成${NC}"

# 步骤3: 生成校验和
echo -e "\n${YELLOW}🔐 步骤3: 生成校验和...${NC}"
cd "$UPLOAD_DIR/org/very/veryoauthsdk/1.0.0"

echo "生成MD5校验和..."
for file in *.aar *.jar *.pom; do
    if [ -f "$file" ]; then
        md5sum "$file" | cut -d' ' -f1 > "$file.md5"
        echo "  ✅ $file.md5"
    fi
done

echo "生成SHA1校验和..."
for file in *.aar *.jar *.pom; do
    if [ -f "$file" ]; then
        sha1sum "$file" | cut -d' ' -f1 > "$file.sha1"
        echo "  ✅ $file.sha1"
    fi
done

echo -e "${GREEN}✅ 校验和生成完成${NC}"

# 步骤4: 生成GPG签名
echo -e "\n${YELLOW}🔑 步骤4: 生成GPG签名...${NC}"

echo "生成GPG签名..."
for file in *.aar *.jar *.pom; do
    if [ -f "$file" ]; then
        echo "  签名: $file"
        gpg --armor --detach-sign "$file"
        if [ -f "$file.asc" ]; then
            echo "  ✅ $file.asc"
        else
            echo -e "${RED}  ❌ $file.asc 生成失败${NC}"
        fi
    fi
done

echo -e "${GREEN}✅ GPG签名生成完成${NC}"

# 步骤5: 创建ZIP包
echo -e "\n${YELLOW}📦 步骤5: 创建ZIP包...${NC}"
cd "$UPLOAD_DIR"

echo "创建ZIP包..."
rm -f veryoauthsdk-1.0.0.zip
zip -r veryoauthsdk-1.0.0.zip org/

ZIP_SIZE=$(du -h veryoauthsdk-1.0.0.zip | cut -f1)
echo -e "${GREEN}✅ ZIP包创建完成: veryoauthsdk-1.0.0.zip ($ZIP_SIZE)${NC}"

# 步骤6: 显示文件清单
echo -e "\n${YELLOW}📋 步骤6: 文件清单...${NC}"
echo "上传目录内容:"
find org/ -type f | sort

echo -e "\n${BLUE}📊 文件统计:${NC}"
echo "AAR文件: $(find org/ -name "*.aar" | wc -l)"
echo "JAR文件: $(find org/ -name "*.jar" | wc -l)"
echo "POM文件: $(find org/ -name "*.pom" | wc -l)"
echo "MD5文件: $(find org/ -name "*.md5" | wc -l)"
echo "SHA1文件: $(find org/ -name "*.sha1" | wc -l)"
echo "ASC文件: $(find org/ -name "*.asc" | wc -l)"

# 步骤7: 显示上传信息
echo -e "\n${YELLOW}🚀 步骤7: 上传信息...${NC}"
echo -e "${BLUE}GPG密钥信息:${NC}"
echo "密钥ID: $GPG_KEY_ID"
echo "指纹: $(gpg --fingerprint $GPG_KEY_ID | grep "指纹" | cut -d' ' -f4-)"

echo -e "\n${BLUE}上传步骤:${NC}"
echo "1. 访问: https://central.sonatype.com/"
echo "2. 登录你的账户"
echo "3. 上传文件: veryoauthsdk-1.0.0.zip"
echo "4. 等待验证完成"

echo -e "\n${BLUE}PGP公钥上传:${NC}"
echo "如果遇到公钥问题，请访问:"
echo "- https://keyserver.ubuntu.com/"
echo "- https://pgp.mit.edu/"
echo "- https://keys.openpgp.org/"
echo "上传你的公钥:"
gpg --armor --export $GPG_KEY_ID

echo -e "\n${GREEN}🎉 构建完成！${NC}"
echo -e "${GREEN}📦 ZIP文件: $UPLOAD_DIR/veryoauthsdk-1.0.0.zip${NC}"
echo -e "${GREEN}📁 上传目录: $UPLOAD_DIR/org/${NC}"
