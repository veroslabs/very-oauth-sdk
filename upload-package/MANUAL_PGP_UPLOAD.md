# 手动上传PGP公钥指南

## 🔑 当前状态

✅ **GPG签名已生成** - 所有文件都有对应的 `.asc` 签名文件
❌ **公钥上传失败** - 自动上传到PGP服务器失败

## 🎯 手动上传解决方案

### 步骤1：访问PGP服务器网站

#### 主要PGP服务器：
1. **keyserver.ubuntu.com**: https://keyserver.ubuntu.com/
2. **pgp.mit.edu**: https://pgp.mit.edu/
3. **keys.openpgp.org**: https://keys.openpgp.org/

### 步骤2：上传公钥

#### 方法1：使用网页表单

1. **访问**: https://keyserver.ubuntu.com/
2. **找到上传区域**: 通常有"Submit a key"或"Upload key"按钮
3. **粘贴公钥**: 复制下面的公钥内容
4. **提交**: 点击"Submit"或"Upload"

#### 方法2：使用邮件

某些PGP服务器支持通过邮件上传：
- 发送公钥到指定的邮件地址
- 在邮件主题中包含"ADD"或"UPLOAD"

## 📋 公钥内容

```
-----BEGIN PGP PUBLIC KEY BLOCK-----

mDMEaPNz4RYJKwYBBAHaRw8BAQdAG3bk+a3iTY4mKTFBJXhgIsLeqalSpZNS/gZ7
cNtymfu0HnRvbmdsaWFuZyA8dG9uZ2xpYW5nQHZlcnkub3JnPoiZBBMWCgBBFiEE
fRcSsWhDp8iL60D5I6q2ELJKRpoFAmjzc+ECGwMFCQWjmoAFCwkIBwICIgIGFQoJ
CAsCBBYCAwECHgcCF4AACgkQI6q2ELJKRpqihwD8DoRh+BenTPIfVIwJ+9rxW1pV
jW9wvomn2TSXvb5c2ewA/0dGAGZX5iX2uDB4vy4bISIkGLjLFtc5EPRiTntbPh8M
uDgEaPNz4RIKKwYBBAGXVQEFAQEHQO6pK4Q6Ttejp+LMjFMHO9dcGEvuwu0IE33S
9gLneK5OAwEIB4h+BBgWCgAmFiEEfRcSsWhDp8iL60D5I6q2ELJKRpoFAmjzc+EC
GwwFCQWjmoAACgkQI6q2ELJKRpqD5AEAsvg1w3TR1RLmGje6hrOrpTEaCIpKAyeF
bLwxSSjfnqIA+gJn7UEoLRwHqQTQ7/CM7QA20feEXJSQM8vNiELV+/4C
=EUGI
-----END PGP PUBLIC KEY BLOCK-----
```

## 🔍 验证上传

### 检查公钥是否已上传

1. **访问**: https://keyserver.ubuntu.com/
2. **搜索**: 输入 `tongliang@very.org` 或 `23AAB610B24A469A`
3. **确认**: 应该能看到你的公钥

### 使用GPG验证

```bash
# 尝试从服务器获取公钥
gpg --keyserver keyserver.ubuntu.com --recv-keys 23AAB610B24A469A

# 如果成功，应该显示公钥信息
gpg --list-keys tongliang@very.org
```

## 🚀 上传到Maven Central

### 一旦公钥上传成功：

1. **等待同步**: PGP服务器同步通常需要几分钟到几小时
2. **重新上传**: 使用相同的ZIP文件重新上传到Maven Central
3. **验证**: Maven Central应该能够找到公钥并验证签名

### 如果仍然失败：

1. **等待更长时间**: 最多等待24小时
2. **尝试多个服务器**: 上传到不同的PGP服务器
3. **联系支持**: 联系Sonatype支持团队

## 📞 替代方案

### 如果PGP上传持续失败：

1. **联系Sonatype支持**: 请求帮助配置公钥
2. **使用不同的GPG密钥**: 生成新的密钥对
3. **考虑使用其他发布方式**: 如JitPack或私有Maven仓库

## ✅ 预期结果

成功上传公钥后：
- ✅ Maven Central能够找到公钥
- ✅ 签名验证通过
- ✅ 所有验证通过
- ✅ 成功发布到Maven Central

---

**注意**: 手动上传公钥是解决PGP服务器连接问题的有效方法。一旦公钥上传成功，你就可以重新上传ZIP文件到Maven Central了！
