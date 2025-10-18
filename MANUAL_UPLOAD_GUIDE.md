# 手动上传到Maven Central指南

## 🎯 概述

由于自动发布遇到401认证问题，我们可以通过 [Sonatype Central Publishing](https://central.sonatype.com/publishing) 手动上传文件到Maven Central。

## 📦 已生成的文件

### 主要文件位置
```
android/veryoauthsdk/build/outputs/aar/veryoauthsdk-release.aar    # 主要AAR文件
android/veryoauthsdk/build/libs/veryoauthsdk-sources.jar           # 源码JAR
android/veryoauthsdk/build/libs/veryoauthsdk-javadoc.jar           # 文档JAR
android/veryoauthsdk/build/publications/release/pom-default.xml     # POM文件
```

### 文件说明
- **veryoauthsdk-release.aar**: 主要的Android库文件
- **veryoauthsdk-sources.jar**: 源码文件，用于IDE代码提示
- **veryoauthsdk-javadoc.jar**: API文档，用于IDE文档显示
- **pom-default.xml**: Maven元数据文件

## 🚀 手动上传步骤

### 1. 访问Sonatype Central Publishing
访问 [https://central.sonatype.com/publishing](https://central.sonatype.com/publishing)

### 2. 登录账户
使用你的Sonatype OSSRH账户登录

### 3. 创建新发布
1. 点击 "Create" 或 "New Publication"
2. 选择 "Maven Central" 作为目标仓库

### 4. 填写发布信息
```
Group ID: org.very
Artifact ID: veryoauthsdk
Version: 1.0.0
```

### 5. 上传文件
按以下顺序上传文件：

#### 主要文件
- **AAR文件**: `veryoauthsdk-release.aar`
- **POM文件**: `pom-default.xml`

#### 附加文件
- **Sources JAR**: `veryoauthsdk-sources.jar`
- **Javadoc JAR**: `veryoauthsdk-javadoc.jar`

### 6. 验证和发布
1. 检查所有文件已正确上传
2. 验证POM文件内容
3. 点击 "Publish" 或 "Release"

## 📋 文件清单

### 必需文件
- [x] `veryoauthsdk-release.aar` - 主要库文件
- [x] `pom-default.xml` - Maven元数据

### 推荐文件
- [x] `veryoauthsdk-sources.jar` - 源码文件
- [x] `veryoauthsdk-javadoc.jar` - 文档文件

## 🔍 验证上传

### 上传成功后
1. 等待同步（通常几分钟到几小时）
2. 在 [Maven Central](https://search.maven.org/) 搜索 `org.very:veryoauthsdk`
3. 验证版本 `1.0.0` 可用

### 用户使用方式
```gradle
dependencies {
    implementation 'org.very:veryoauthsdk:1.0.0'
}
```

## 🛠️ 故障排除

### 常见问题
1. **文件格式错误**: 确保AAR文件是有效的Android库
2. **POM文件问题**: 检查POM文件中的元数据
3. **权限问题**: 确保账户有`org.very`组ID的发布权限

### 验证命令
```bash
# 检查AAR文件
file veryoauthsdk-release.aar

# 检查JAR文件
file veryoauthsdk-sources.jar
file veryoauthsdk-javadoc.jar

# 检查POM文件
cat pom-default.xml
```

## 📞 支持

如果遇到问题：
1. 检查 [Sonatype Central Publishing](https://central.sonatype.com/publishing) 文档
2. 联系Sonatype技术支持
3. 查看上传日志和错误信息

## 🎉 成功指标

发布成功后，用户应该能够：
1. 在Maven Central搜索到库
2. 使用Gradle依赖添加库
3. 在IDE中获得代码提示和文档

---

**注意**: 手动上传是发布到Maven Central的有效方式，特别适合解决自动化发布中的认证问题。
