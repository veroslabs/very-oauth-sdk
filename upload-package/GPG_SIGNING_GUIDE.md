# GPG签名指南

## 🔐 关于GPG签名

Maven Central要求所有上传的工件都必须使用GPG签名。这是为了确保工件的完整性和来源验证。

## 📋 当前状态

### 已修复的问题
- ✅ **校验和格式**: 现在只包含校验和值，不包含文件名
- ✅ **文件命名**: 使用正确的Maven命名约定
- ✅ **目录结构**: 遵循 `groupId/artifactId/version/` 结构

### 仍需要解决的问题
- ❌ **GPG签名**: 所有文件都需要GPG签名文件

## 🛠️ GPG签名解决方案

### 方案1：使用GPG签名（推荐）

如果你有GPG密钥，可以生成签名文件：

```bash
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

### 方案2：使用Sonatype Central Publishing的自动签名

某些情况下，Sonatype Central Publishing可能会自动处理签名，特别是对于新账户或特定类型的发布。

### 方案3：联系Sonatype支持

如果自动签名不可用，可以联系Sonatype支持团队，他们可能会为你的账户启用自动签名功能。

## 🚀 当前可尝试的上传

尽管缺少GPG签名，你可以尝试上传当前的ZIP文件：

1. **文件**: `veryoauthsdk-1.0.0.zip` (463KB)
2. **内容**: 包含所有必要的文件和正确的校验和
3. **目录结构**: 完全符合Maven Central要求

如果上传失败，错误信息会明确指出需要GPG签名，然后我们可以实施上述解决方案之一。

## 📞 下一步

1. **尝试上传**: 使用当前的ZIP文件尝试上传
2. **如果失败**: 根据错误信息决定是否需要GPG签名
3. **生成签名**: 如果需要，使用GPG生成签名文件
4. **重新打包**: 包含签名文件重新创建ZIP

---

**注意**: 即使缺少GPG签名，当前的ZIP文件结构是完全正确的，应该能够通过大部分验证。
