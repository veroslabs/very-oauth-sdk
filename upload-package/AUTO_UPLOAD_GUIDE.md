# 自动上传到 Maven Central 指南

## 🤖 关于自动上传

### 当前状态

- ✅ **手动上传**: 通过 [https://central.sonatype.com/](https://central.sonatype.com/) 手动上传 ZIP 文件
- ❌ **自动上传**: 目前没有直接的 API 支持自动上传

## 🔍 Maven Central 上传方式分析

### 方式 1：手动上传（当前推荐）

- **优点**: 简单直接，支持 ZIP 文件上传
- **缺点**: 需要手动操作
- **适用**: 一次性发布或测试

### 方式 2：Gradle Maven 插件（需要配置）

- **优点**: 自动化程度高
- **缺点**: 需要复杂的 GPG 配置和认证
- **适用**: 持续集成和自动化发布

### 方式 3：Sonatype Central Publishing API ✅

- **状态**: **有公开的API！** 🎉
- **API文档**: [https://central.sonatype.org/publish/publish-portal-api/](https://central.sonatype.org/publish/publish-portal-api/)
- **功能**: 完全自动化上传、状态监控、自动发布

## 🛠️ 自动化解决方案

### 方案 1：使用 Sonatype Central Publishing API（最新推荐）🚀

#### 完全自动化脚本
```bash
# 设置认证信息
export CENTRAL_USERNAME=your_username
export CENTRAL_PASSWORD=your_password

# 运行完整自动化流程
./scripts/complete-automation.sh
```

#### API功能特性
- ✅ **自动上传**: 通过API上传ZIP文件
- ✅ **状态监控**: 实时监控部署状态
- ✅ **自动发布**: 验证通过后自动发布
- ✅ **错误处理**: 完整的错误处理和重试机制

#### API端点
- **上传**: `POST /api/v1/publisher/upload`
- **状态检查**: `POST /api/v1/publisher/status`
- **发布**: `POST /api/v1/publisher/deployment/{id}`

### 方案 2：使用 Gradle Maven 插件（传统方式）

#### 配置 build.gradle

```gradle
plugins {
    id 'maven-publish'
    id 'signing'
}

publishing {
    publications {
        release(MavenPublication) {
            from components.release

            groupId = 'org.very'
            artifactId = 'veryoauthsdk'
            version = '1.0.0'

            pom {
                name = 'VeryOauthSDK'
                description = 'A comprehensive OAuth 2.0 SDK for Android'
                url = 'https://github.com/veroslabs/very-oauth-sdk'

                licenses {
                    license {
                        name = 'MIT License'
                        url = 'https://opensource.org/licenses/MIT'
                    }
                }

                developers {
                    developer {
                        id = 'veroslabs'
                        name = 'Veros Labs Team'
                        email = 'tongliang@very.org'
                    }
                }

                scm {
                    connection = 'scm:git:git://github.com/veroslabs/very-oauth-sdk.git'
                    developerConnection = 'scm:git:ssh://github.com:veroslabs/very-oauth-sdk.git'
                    url = 'https://github.com/veroslabs/very-oauth-sdk'
                }
            }
        }
    }

    repositories {
        maven {
            name = "sonatype"
            url = "https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/"
            credentials {
                username = project.findProperty("ossrhUsername") ?: System.getenv("OSSRH_USERNAME")
                password = project.findProperty("ossrhPassword") ?: System.getenv("OSSRH_PASSWORD")
            }
        }
    }
}

signing {
    required { gradle.taskGraph.hasTask("publish") }
    sign publishing.publications.release
}
```

#### 运行发布命令

```bash
cd android
./gradlew publish
```

### 方案 3：使用 GitHub Actions 自动化

#### 创建 GitHub Actions 工作流

```yaml
name: Publish to Maven Central

on:
  push:
    tags:
      - "v*"

jobs:
  publish:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          java-version: "8"
          distribution: "temurin"

      - name: Set up GPG
        run: |
          gpg --batch --import <<< "${{ secrets.GPG_PRIVATE_KEY }}"
          gpg --batch --import-ownertrust <<< "${{ secrets.GPG_OWNERTRUST }}"

      - name: Publish to Maven Central
        run: |
          cd android
          ./gradlew publish
        env:
          OSSRH_USERNAME: ${{ secrets.OSSRH_USERNAME }}
          OSSRH_PASSWORD: ${{ secrets.OSSRH_PASSWORD }}
          SIGNING_KEY_ID: ${{ secrets.SIGNING_KEY_ID }}
          SIGNING_PASSWORD: ${{ secrets.SIGNING_PASSWORD }}
          SIGNING_SECRET_KEY_RING_FILE: ${{ secrets.SIGNING_SECRET_KEY_RING_FILE }}
```

### 方案 4：使用第三方工具

#### 使用 Maven Central Publisher

```bash
# 安装工具
npm install -g maven-central-publisher

# 发布
maven-central-publisher publish \
  --groupId org.very \
  --artifactId veryoauthsdk \
  --version 1.0.0 \
  --file veryoauthsdk-1.0.0.zip
```

## 🚀 推荐方案

### 对于当前项目

1. **立即可用**: 使用 Sonatype Central Publishing API（推荐）
2. **短期**: 配置 Gradle Maven 插件
3. **长期**: 设置 GitHub Actions 自动化

### 实施步骤

1. **设置认证**: 配置 Central 账户凭据
2. **运行脚本**: 使用 `./scripts/complete-automation.sh`
3. **监控状态**: 脚本会自动监控发布状态
4. **验证发布**: 检查 Maven Central 上的包

## 📋 当前可用的自动化脚本

### 1. 完整构建脚本
```bash
# 运行完整构建流程
./scripts/build-and-sign-android.sh
```

### 2. 自动上传脚本
```bash
# 设置认证信息
export CENTRAL_USERNAME=your_username
export CENTRAL_PASSWORD=your_password

# 自动上传到Maven Central
./scripts/auto-upload-to-central.sh
```

### 3. 完整自动化脚本（推荐）
```bash
# 设置认证信息
export CENTRAL_USERNAME=your_username
export CENTRAL_PASSWORD=your_password

# 运行完整自动化流程（构建+上传）
./scripts/complete-automation.sh
```

### 脚本功能

#### 构建脚本功能
- ✅ 清理和构建项目
- ✅ 生成所有必要的文件
- ✅ 创建校验和
- ✅ 生成 GPG 签名
- ✅ 打包成 ZIP 文件
- ✅ 准备上传目录

#### 上传脚本功能
- ✅ 自动上传ZIP文件
- ✅ 实时监控部署状态
- ✅ 自动发布到Maven Central
- ✅ 完整的错误处理
- ✅ 状态报告和URL显示

### 使用步骤

1. **设置认证**: 配置 Central 账户凭据
2. **运行脚本**: `./scripts/complete-automation.sh`
3. **等待完成**: 脚本会自动处理所有步骤
4. **验证发布**: 检查 Maven Central 上的包

## 🔗 相关链接

- [Maven Central Publishing](https://central.sonatype.com/)
- [Sonatype Central Publishing API](https://central.sonatype.org/publish/publish-portal-api/)
- [API文档](https://central.sonatype.com/api-doc)
- [Sonatype OSSRH](https://s01.oss.sonatype.org/)
- [Gradle Maven Plugin](https://docs.gradle.org/current/userguide/publishing_maven.html)
- [GitHub Actions](https://github.com/features/actions)

---

**注意**: 现在完全自动化上传已经实现！使用 `./scripts/complete-automation.sh` 可以一键完成从构建到发布的整个流程。
