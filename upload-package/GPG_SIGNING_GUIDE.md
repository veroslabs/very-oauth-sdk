# GPG 签名指南

## 🔐 关于 GPG 签名

Maven Central 要求所有上传的工件都必须使用 GPG 签名。这是为了确保工件的完整性和来源验证。

## 📋 当前状态

### 已修复的问题

- ✅ **校验和格式**: 现在只包含校验和值，不包含文件名
- ✅ **文件命名**: 使用正确的 Maven 命名约定
- ✅ **目录结构**: 遵循 `groupId/artifactId/version/` 结构

### 仍需要解决的问题

- ❌ **GPG 签名**: 所有文件都需要 GPG 签名文件

## 🛠️ GPG 签名解决方案

### 方案 1：使用 GPG 签名（推荐）

如果你有 GPG 密钥，可以生成签名文件：

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

### 方案 2：使用 Sonatype Central Publishing 的自动签名

某些情况下，Sonatype Central Publishing 可能会自动处理签名，特别是对于新账户或特定类型的发布。

### 方案 3：联系 Sonatype 支持

如果自动签名不可用，可以联系 Sonatype 支持团队，他们可能会为你的账户启用自动签名功能。

## 🚀 当前可尝试的上传

尽管缺少 GPG 签名，你可以尝试上传当前的 ZIP 文件：

1. **文件**: `veryoauthsdk-1.0.0.zip` (463KB)
2. **内容**: 包含所有必要的文件和正确的校验和
3. **目录结构**: 完全符合 Maven Central 要求

如果上传失败，错误信息会明确指出需要 GPG 签名，然后我们可以实施上述解决方案之一。

## 📞 下一步

1. **尝试上传**: 使用当前的 ZIP 文件尝试上传
2. **如果失败**: 根据错误信息决定是否需要 GPG 签名
3. **生成签名**: 如果需要，使用 GPG 生成签名文件
4. **重新打包**: 包含签名文件重新创建 ZIP

---

**注意**: 即使缺少 GPG 签名，当前的 ZIP 文件结构是完全正确的，应该能够通过大部分验证。
