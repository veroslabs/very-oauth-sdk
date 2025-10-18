# Maven Central 正确上传指南

## 📦 正确的目录结构

```
upload-package/
└── org/
    └── very/
        └── veryoauthsdk/
            └── 1.0.0/
                ├── veryoauthsdk-1.0.0.aar
                ├── veryoauthsdk-1.0.0.aar.md5
                ├── veryoauthsdk-1.0.0.aar.sha1
                ├── veryoauthsdk-1.0.0.pom
                ├── veryoauthsdk-1.0.0.pom.md5
                ├── veryoauthsdk-1.0.0.pom.sha1
                ├── veryoauthsdk-1.0.0-sources.jar
                ├── veryoauthsdk-1.0.0-sources.jar.md5
                ├── veryoauthsdk-1.0.0-sources.jar.sha1
                ├── veryoauthsdk-1.0.0-javadoc.jar
                ├── veryoauthsdk-1.0.0-javadoc.jar.md5
                └── veryoauthsdk-1.0.0-javadoc.jar.sha1
```

## 🎯 文件命名规则

### 主要文件

- `veryoauthsdk-1.0.0.aar` - 主要 Android 库文件
- `veryoauthsdk-1.0.0.pom` - Maven 元数据文件

### 附加文件

- `veryoauthsdk-1.0.0-sources.jar` - 源码文件
- `veryoauthsdk-1.0.0-javadoc.jar` - API 文档

### 校验和文件

- 每个文件都有对应的 `.md5` 和 `.sha1` 校验和文件

## 📋 上传步骤

### 1. 压缩为 ZIP 文件

```bash
cd upload-package
zip -r veryoauthsdk-1.0.0.zip org/
```

### 2. 访问上传页面

- 打开 [https://central.sonatype.com/publishing](https://central.sonatype.com/publishing)
- 使用 Sonatype OSSRH 账户登录

### 3. 上传 ZIP 文件

- 上传 `veryoauthsdk-1.0.0.zip` 文件
- 系统会自动解压并验证目录结构

### 4. 验证上传

- 检查所有文件都已正确识别
- 验证校验和文件
- 确认目录结构正确

## ✅ 关键改进

### 文件命名

- ✅ 使用正确的 Maven 命名约定：`artifactId-version-classifier.extension`
- ✅ AAR 文件：`veryoauthsdk-1.0.0.aar`
- ✅ POM 文件：`veryoauthsdk-1.0.0.pom`
- ✅ Sources JAR：`veryoauthsdk-1.0.0-sources.jar`
- ✅ Javadoc JAR：`veryoauthsdk-1.0.0-javadoc.jar`

### 目录结构

- ✅ 遵循 Maven 仓库结构：`groupId/artifactId/version/`
- ✅ 路径：`org/very/veryoauthsdk/1.0.0/`

### 校验和文件

- ✅ 每个文件都有 MD5 和 SHA1 校验和
- ✅ 校验和文件命名：`filename.md5` 和 `filename.sha1`

## 🚀 用户使用方式

发布成功后，用户可以通过以下方式使用：

```gradle
dependencies {
    implementation 'org.very:veryoauthsdk:1.0.0'
}
```

## 📞 故障排除

### 常见问题

1. **文件命名错误**: 确保使用正确的 Maven 命名约定
2. **目录结构错误**: 确保遵循 `groupId/artifactId/version/` 结构
3. **缺少校验和**: 确保每个文件都有对应的校验和文件
4. **ZIP 压缩**: 确保压缩时保持目录结构

### 验证命令

```bash
# 检查目录结构
find org/ -type f | sort

# 验证校验和
md5sum org/very/veryoauthsdk/1.0.0/*.aar
sha1sum org/very/veryoauthsdk/1.0.0/*.jar
```

---

**注意**: 这个目录结构完全符合 Maven Central 的要求，应该能够成功通过验证。
