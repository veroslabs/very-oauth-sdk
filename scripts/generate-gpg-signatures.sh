#!/bin/bash

# GPG签名生成脚本
# 用于为Maven Central上传生成必需的GPG签名文件

set -e

echo "🔐 GPG签名生成脚本"
echo "=================="

# 检查GPG是否安装
if ! command -v gpg &> /dev/null; then
    echo "❌ GPG未安装"
    echo "请先安装GPG:"
    echo "  macOS: brew install gnupg"
    echo "  Ubuntu: sudo apt-get install gnupg"
    echo "  Windows: 下载 https://gnupg.org/download/"
    exit 1
fi

echo "✅ GPG已安装"

# 检查是否有GPG密钥
if ! gpg --list-secret-keys --keyid-format LONG | grep -q "sec"; then
    echo "❌ 没有找到GPG密钥"
    echo "请先生成GPG密钥:"
    echo "  gpg --full-generate-key"
    echo "  选择 RSA and RSA (default)"
    echo "  密钥大小: 4096"
    echo "  有效期: 0 (永不过期)"
    exit 1
fi

echo "✅ 找到GPG密钥"

# 进入文件目录
cd upload-package/org/very/veryoauthsdk/1.0.0/

echo "📁 当前目录: $(pwd)"
echo "📋 需要签名的文件:"

# 列出需要签名的文件
for file in *.aar *.jar *.pom; do
    if [ -f "$file" ]; then
        echo "  - $file"
    fi
done

echo ""
echo "🔐 开始生成GPG签名..."

# 为每个文件生成GPG签名
for file in *.aar *.jar *.pom; do
    if [ -f "$file" ]; then
        echo "正在签名: $file"
        gpg --armor --detach-sign "$file"
        if [ -f "$file.asc" ]; then
            echo "  ✅ 生成签名: $file.asc"
        else
            echo "  ❌ 签名生成失败: $file"
        fi
    fi
done

echo ""
echo "📋 生成的文件:"
ls -la *.asc 2>/dev/null || echo "没有找到.asc文件"

echo ""
echo "🎯 下一步:"
echo "1. 检查所有.asc文件已生成"
echo "2. 运行: cd ../../.. && zip -r veryoauthsdk-1.0.0.zip org/"
echo "3. 上传新的ZIP文件到Maven Central"

echo ""
echo "✨ 完成！"
