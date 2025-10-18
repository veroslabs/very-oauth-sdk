# Android Maven Publishing Setup

## 概述

本文档说明如何将 VeryOauthSDK Android 库发布到 Maven Central。

## 配置完成情况

✅ **Maven 发布配置已完成**

- `android/veryoauthsdk/build.gradle` 已配置 Maven 发布
- 支持签名和 POM 元数据
- 配置了 Sonatype OSSRH 仓库

✅ **发布脚本已创建**

- `scripts/publish-android.sh` 自动化发布脚本
- 支持本地测试和远程发布

✅ **文档已更新**

- `MAVEN_PUBLISH.md` 详细发布指南
- Android README.md 已更新 Maven 依赖信息

## 发布前准备

### 1. Sonatype OSSRH 账户设置

1. 注册 [Sonatype OSSRH](https://s01.oss.sonatype.org/) 账户
2. 创建新项目工单，申请 `com.veryoauthsdk` 组 ID
3. 等待审批（通常几小时到一天）

### 2. GPG 密钥设置

```bash
# 生成GPG密钥
gpg --gen-key

# 列出密钥
gpg --list-secret-keys

# 导出公钥
gpg --armor --export your_key_id > public_key.asc

# 上传到密钥服务器
gpg --keyserver keyserver.ubuntu.com --send-keys your_key_id
```

### 3. 环境变量设置

在 `~/.gradle/gradle.properties` 中添加：

```properties
# OSSRH认证信息
ossrhUsername=your_sonatype_username
ossrhPassword=your_sonatype_password

# GPG签名配置
signing.keyId=your_gpg_key_id
signing.password=your_gpg_key_password
signing.secretKeyRingFile=/path/to/your/secret.gpg
```

## 发布步骤

### 方法 1：使用发布脚本（推荐）

```bash
# 设置环境变量
export OSSRH_USERNAME=your_username
export OSSRH_PASSWORD=your_password
export SIGNING_KEY_ID=your_key_id
export SIGNING_PASSWORD=your_key_password

# 运行发布脚本
./scripts/publish-android.sh
```

### 方法 2：手动发布

```bash
cd android

# 清理和构建
./gradlew :veryoauthsdk:clean :veryoauthsdk:build

# 生成文档
./gradlew :veryoauthsdk:dokkaHtml

# 发布到本地Maven仓库（测试用）
./gradlew :veryoauthsdk:publishToMavenLocal

# 发布到Sonatype暂存仓库
./gradlew :veryoauthsdk:publishReleasePublicationToSonatypeRepository
```

## 发布后操作

1. 访问 [Sonatype OSSRH](https://s01.oss.sonatype.org/)
2. 进入 "Staging Repositories"
3. 找到你的上传仓库
4. 选择并点击 "Close"
5. 等待验证完成
6. 点击 "Release" 发布到 Maven Central

## 使用方式

发布成功后，用户可以通过以下方式使用：

```gradle
dependencies {
    implementation 'com.veryoauthsdk:veryoauthsdk:1.0.0'
}
```

## 故障排除

### 常见问题

1. **认证失败**: 检查 OSSRH 凭据
2. **签名失败**: 验证 GPG 密钥配置
3. **验证失败**: 确保 POM 元数据完整

### 测试命令

```bash
# 检查配置
./gradlew :veryoauthsdk:publishReleasePublicationToSonatypeRepository --dry-run

# 本地测试
./gradlew :veryoauthsdk:publishToMavenLocal
```

## 版本管理

更新版本时：

1. 修改 `android/veryoauthsdk/build.gradle` 中的 `versionName`
2. 更新发布配置中的 `version`
3. 创建新的 Git 标签
4. 重新发布

## 安全注意事项

- 不要将凭据提交到版本控制
- 使用环境变量或安全的凭据存储
- 妥善保管 GPG 密钥并做好备份
