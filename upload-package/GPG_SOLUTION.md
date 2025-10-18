# GPG签名解决方案

## 🎯 当前状态

✅ **校验和问题已解决** - 所有MD5和SHA1校验和格式正确
❌ **GPG签名缺失** - 需要为所有文件生成GPG签名

## 🔐 GPG签名解决方案

### 方案1：安装GPG并生成签名（推荐）

#### 1. 安装GPG
```bash
# macOS
brew install gnupg

# 或者下载安装包
# https://gnupg.org/download/
```

#### 2. 生成GPG密钥（如果没有）
```bash
gpg --full-generate-key
# 选择 RSA and RSA (default)
# 密钥大小: 4096
# 有效期: 0 (永不过期)
# 输入姓名和邮箱
```

#### 3. 生成签名文件
```bash
cd upload-package/org/very/veryoauthsdk/1.0.0/

# 为每个文件生成GPG签名
gpg --armor --detach-sign veryoauthsdk-1.0.0.aar
gpg --armor --detach-sign veryoauthsdk-1.0.0.pom
gpg --armor --detach-sign veryoauthsdk-1.0.0-sources.jar
gpg --armor --detach-sign veryoauthsdk-1.0.0-javadoc.jar
```

这会生成 `.asc` 文件：
- `veryoauthsdk-1.0.0.aar.asc`
- `veryoauthsdk-1.0.0.pom.asc`
- `veryoauthsdk-1.0.0-sources.jar.asc`
- `veryoauthsdk-1.0.0-javadoc.jar.asc`

#### 4. 重新打包ZIP
```bash
cd /Users/yan/Desktop/veros/very-oauth-sdk/upload-package
rm veryoauthsdk-1.0.0.zip
zip -r veryoauthsdk-1.0.0.zip org/
```

### 方案2：使用在线GPG工具

1. 访问 [https://www.gpg4win.org/](https://www.gpg4win.org/) 或类似工具
2. 上传文件并生成签名
3. 下载 `.asc` 文件

### 方案3：联系Sonatype支持

1. 访问 [https://central.sonatype.com/](https://central.sonatype.com/)
2. 联系支持团队
3. 请求为你的账户启用自动签名功能

## 📋 完整的文件清单

上传时需要包含以下文件：

```
org/very/veryoauthsdk/1.0.0/
├── veryoauthsdk-1.0.0.aar
├── veryoauthsdk-1.0.0.aar.asc          ← GPG签名
├── veryoauthsdk-1.0.0.aar.md5
├── veryoauthsdk-1.0.0.aar.sha1
├── veryoauthsdk-1.0.0.pom
├── veryoauthsdk-1.0.0.pom.asc          ← GPG签名
├── veryoauthsdk-1.0.0.pom.md5
├── veryoauthsdk-1.0.0.pom.sha1
├── veryoauthsdk-1.0.0-sources.jar
├── veryoauthsdk-1.0.0-sources.jar.asc  ← GPG签名
├── veryoauthsdk-1.0.0-sources.jar.md5
├── veryoauthsdk-1.0.0-sources.jar.sha1
├── veryoauthsdk-1.0.0-javadoc.jar
├── veryoauthsdk-1.0.0-javadoc.jar.asc  ← GPG签名
├── veryoauthsdk-1.0.0-javadoc.jar.md5
└── veryoauthsdk-1.0.0-javadoc.jar.sha1
```

## 🚀 快速开始

1. **安装GPG**: `brew install gnupg`
2. **生成密钥**: `gpg --full-generate-key`
3. **生成签名**: 运行上述gpg命令
4. **重新打包**: 创建新的ZIP文件
5. **上传**: 使用新的ZIP文件上传

## 📞 如果遇到问题

- **GPG安装问题**: 查看 [GPG官方文档](https://gnupg.org/documentation/)
- **签名生成问题**: 确保密钥已正确配置
- **上传问题**: 联系Sonatype支持团队

---

**注意**: 一旦生成了GPG签名文件，你就可以成功上传到Maven Central了！
