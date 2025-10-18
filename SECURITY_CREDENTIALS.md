# 安全凭据管理指南

## 🔒 凭据安全最佳实践

### ❌ 不推荐：直接在 gradle.properties 中存储凭据

```properties
# 不要这样做 - 凭据会被提交到Git仓库
ossrhUsername=your_username
ossrhPassword=your_password
```

### ✅ 推荐方式

#### 方式 1：环境变量（最推荐）

```bash
# 在终端中设置环境变量
export OSSRH_USERNAME=your_username
export OSSRH_PASSWORD=your_password

# 或者添加到 ~/.bashrc 或 ~/.zshrc
echo 'export OSSRH_USERNAME=your_username' >> ~/.bashrc
echo 'export OSSRH_PASSWORD=your_password' >> ~/.bashrc
```

#### 方式 2：本地 gradle.properties（不提交到 Git）

在 `android/gradle.properties` 中：

```properties
# 这些凭据不会被提交到Git仓库
ossrhUsername=your_username
ossrhPassword=your_password
```

**重要**：确保 `gradle.properties` 在 `.gitignore` 中被忽略。

#### 方式 3：使用 Gradle 的凭据存储

```bash
# 使用Gradle凭据存储
./gradlew --write-only --write-locks publishReleasePublicationToSonatypeRepository
```

## 🛡️ 安全配置步骤

### 1. 检查.gitignore

确保 `android/gradle.properties` 在 `.gitignore` 中：

```gitignore
# Gradle
android/gradle.properties
android/local.properties
```

### 2. 设置环境变量

```bash
# 设置OSSRH凭据
export OSSRH_USERNAME=16Be1V
export OSSRH_PASSWORD=vpBbpo3vSwNdIR3Th15WDUxRCdtFYatny

# 设置GPG签名凭据
export SIGNING_KEY_ID=your_gpg_key_id
export SIGNING_PASSWORD=your_gpg_key_password
```

### 3. 验证配置

```bash
# 检查环境变量是否设置
echo $OSSRH_USERNAME
echo $OSSRH_PASSWORD

# 测试发布（不实际上传）
cd android
./gradlew :veryoauthsdk:publishReleasePublicationToSonatypeRepository --dry-run
```

## 🔧 发布脚本使用

使用我们提供的发布脚本：

```bash
# 设置环境变量
export OSSRH_USERNAME=16Be1V
export OSSRH_PASSWORD=vpBbpo3vSwNdIR3Th15WDUxRCdtFYatny
export SIGNING_KEY_ID=your_gpg_key_id
export SIGNING_PASSWORD=your_gpg_key_password

# 运行发布脚本
./scripts/publish-android.sh
```

## 🚨 安全注意事项

1. **永远不要**将凭据提交到 Git 仓库
2. **使用环境变量**而不是硬编码凭据
3. **定期轮换**凭据和密钥
4. **使用最小权限**原则
5. **监控**凭据使用情况

## 📝 凭据管理清单

- [ ] 从 gradle.properties 中移除硬编码凭据
- [ ] 设置环境变量
- [ ] 验证.gitignore 包含敏感文件
- [ ] 测试发布配置
- [ ] 记录凭据轮换计划

## 🔍 故障排除

### 凭据未找到错误

```
Could not find property 'ossrhUsername'
```

**解决方案**：

1. 检查环境变量是否设置：`echo $OSSRH_USERNAME`
2. 确保在正确的 shell 会话中设置
3. 重启终端或重新加载配置

### 认证失败

```
Authentication failed for repository
```

**解决方案**：

1. 验证凭据是否正确
2. 检查 Sonatype OSSRH 账户状态
3. 确认组 ID 已获得批准
