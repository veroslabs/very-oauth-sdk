# Maven Central 手动上传清单

## 📦 文件清单

### 主要文件
- [x] `veryoauthsdk-release.aar` (75KB) - 主要Android库文件
- [x] `veryoauthsdk-1.0.0.pom` (1.2KB) - Maven元数据文件（.pom扩展名）

### 附加文件
- [x] `veryoauthsdk-sources.jar` (7.4KB) - 源码文件
- [x] `veryoauthsdk-javadoc.jar` (415KB) - API文档

## 🎯 上传信息

### 发布信息
```
Group ID: org.very
Artifact ID: veryoauthsdk
Version: 1.0.0
```

### 目标仓库
- **Maven Central** (通过 Sonatype Central Publishing)

## 📋 上传步骤

### 1. 访问上传页面
- 打开 [https://central.sonatype.com/publishing](https://central.sonatype.com/publishing)
- 使用Sonatype OSSRH账户登录

### 2. 创建新发布
- 点击 "Create" 或 "New Publication"
- 选择 "Maven Central" 作为目标

### 3. 填写发布信息
```
Group ID: org.very
Artifact ID: veryoauthsdk
Version: 1.0.0
```

### 4. 上传文件
按顺序上传以下文件：

1. **主要文件**
   - `veryoauthsdk-release.aar`
   - `veryoauthsdk-1.0.0.pom` ⭐ (注意：这是.pom文件)

2. **附加文件**
   - `veryoauthsdk-sources.jar`
   - `veryoauthsdk-javadoc.jar`

### 5. 验证和发布
- 检查所有文件已正确上传
- 验证POM文件内容
- 点击 "Publish" 或 "Release"

## ✅ 验证清单

### 上传前检查
- [x] 所有4个文件已准备就绪
- [x] 文件大小合理（AAR: 75KB, POM: 1.2KB, Sources: 7.4KB, Javadoc: 415KB）
- [x] POM文件有正确的.pom扩展名
- [x] 账户有`org.very`组ID的发布权限

### 上传后验证
- [ ] 在Maven Central搜索 `org.very:veryoauthsdk`
- [ ] 验证版本 `1.0.0` 可用
- [ ] 测试Gradle依赖添加

## 🚀 用户使用方式

发布成功后，用户可以通过以下方式使用：

```gradle
dependencies {
    implementation 'org.very:veryoauthsdk:1.0.0'
}
```

## 📞 支持

如果遇到问题：
1. 检查文件完整性
2. 验证账户权限
3. 联系Sonatype技术支持

---

**注意**: 手动上传是发布到Maven Central的有效方式，特别适合解决自动化发布中的认证问题。确保POM文件有正确的.pom扩展名。