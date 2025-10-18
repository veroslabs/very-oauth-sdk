# Android Maven发布问题诊断

## 🎉 好消息

- ✅ `org.very`组ID已获得Sonatype OSSRH批准
- ✅ Android SDK构建成功
- ✅ 本地Maven发布成功
- ✅ Maven发布配置完整

## ⚠️ 当前问题

### 401认证错误
```
Could not PUT 'https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/org/very/veryoauthsdk/1.0.0/veryoauthsdk-1.0.0.aar'
Received status code 401 from server: Content access is protected by token
```

## 🔍 可能的原因和解决方案

### 1. 认证方式问题
**可能原因**：Sonatype OSSRH可能需要使用不同的认证方式

**解决方案**：
- 检查是否需要使用API Token而不是用户名/密码
- 验证账户是否有正确的权限

### 2. GPG签名要求
**可能原因**：Maven Central要求所有工件必须进行GPG签名

**解决方案**：
```bash
# 安装GPG
brew install gnupg

# 生成GPG密钥
gpg --gen-key

# 导出公钥
gpg --armor --export your_key_id > public_key.asc

# 上传到密钥服务器
gpg --keyserver keyserver.ubuntu.com --send-keys your_key_id
```

### 3. 账户权限问题
**可能原因**：账户可能没有正确的发布权限

**解决方案**：
- 登录 [Sonatype OSSRH](https://s01.oss.sonatype.org/)
- 检查账户状态和权限
- 确认组ID已正确关联到账户

### 4. 凭据问题
**可能原因**：用户名或密码不正确

**解决方案**：
- 验证凭据是否正确
- 尝试重置密码
- 检查账户是否被锁定

## 🚀 建议的解决步骤

### 步骤1：验证账户状态
1. 登录 [Sonatype OSSRH](https://s01.oss.sonatype.org/)
2. 检查账户状态
3. 确认`org.very`组ID已关联

### 步骤2：设置GPG签名
```bash
# 安装GPG
brew install gnupg

# 生成密钥
gpg --gen-key

# 配置gradle.properties
signing.keyId=your_key_id
signing.password=your_key_password
signing.secretKeyRingFile=/path/to/your/secret.gpg
```

### 步骤3：尝试不同的认证方式
```gradle
// 在build.gradle中尝试不同的认证方式
repositories {
    maven {
        name = "sonatype"
        url = "https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/"
        credentials {
            username = project.findProperty("ossrhUsername")
            password = project.findProperty("ossrhPassword")
        }
    }
}
```

### 步骤4：联系Sonatype支持
如果以上步骤都无法解决问题，建议：
1. 查看Sonatype OSSRH文档
2. 联系Sonatype技术支持
3. 检查是否有其他认证要求

## 📋 当前配置状态

### ✅ 已配置
- Maven发布配置
- POM元数据
- 工件生成（AAR、源码、文档）
- 组ID更新为`org.very`

### ⏳ 待解决
- Sonatype OSSRH认证
- GPG签名配置
- 远程发布成功

## 🔧 测试命令

```bash
# 本地测试（已成功）
./gradlew :veryoauthsdk:publishToMavenLocal

# 远程发布（当前失败）
./gradlew :veryoauthsdk:publishReleasePublicationToSonatypeRepository

# 检查配置
./gradlew :veryoauthsdk:publishReleasePublicationToSonatypeRepository --dry-run
```

## 📞 下一步行动

1. **立即行动**：检查Sonatype OSSRH账户状态
2. **设置GPG**：配置GPG签名
3. **验证凭据**：确认认证信息正确
4. **联系支持**：如果问题持续，联系Sonatype技术支持

## 🎯 成功指标

发布成功后，用户应该能够：
```gradle
dependencies {
    implementation 'org.very:veryoauthsdk:1.0.0'
}
```

并且库将在Maven Central上可用。
