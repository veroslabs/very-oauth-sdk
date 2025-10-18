# PGP公钥上传指南

## 🔑 当前状态

✅ **GPG签名已生成** - 所有文件都有对应的 `.asc` 签名文件
❌ **公钥未上传** - Maven Central无法找到对应的公钥

## 🎯 解决方案

### 步骤1：获取公钥指纹

你的GPG密钥信息：
```
密钥ID: 23AAB610B24A469A
指纹: 7D1712B16843A7C88BEB40F923AAB610B24A469A
邮箱: tongliang@very.org
```

### 步骤2：上传公钥到PGP服务器

#### 方法1：使用GPG命令（推荐）

```bash
# 上传到默认PGP服务器
gpg --send-keys 23AAB610B24A469A

# 上传到多个PGP服务器
gpg --keyserver keyserver.ubuntu.com --send-keys 23AAB610B24A469A
gpg --keyserver pgp.mit.edu --send-keys 23AAB610B24A469A
gpg --keyserver keys.openpgp.org --send-keys 23AAB610B24A469A
```

#### 方法2：手动上传

1. **访问PGP服务器网站**:
   - [keyserver.ubuntu.com](https://keyserver.ubuntu.com/)
   - [pgp.mit.edu](https://pgp.mit.edu/)
   - [keys.openpgp.org](https://keys.openpgp.org/)

2. **上传公钥**:
   - 复制下面的公钥内容
   - 粘贴到上传表单中
   - 点击"Submit"或"Upload"

### 步骤3：验证上传

```bash
# 检查公钥是否已上传
gpg --keyserver keyserver.ubuntu.com --recv-keys 23AAB610B24A469A
```

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

## 🚀 完整流程

### 1. 上传公钥
```bash
gpg --keyserver keyserver.ubuntu.com --send-keys 23AAB610B24A469A
gpg --keyserver pgp.mit.edu --send-keys 23AAB610B24A469A
gpg --keyserver keys.openpgp.org --send-keys 23AAB610B24A469A
```

### 2. 等待同步
- PGP服务器同步通常需要几分钟到几小时
- 可以尝试多次上传到不同服务器

### 3. 验证上传
```bash
gpg --keyserver keyserver.ubuntu.com --recv-keys 23AAB610B24A469A
```

### 4. 重新上传到Maven Central
- 使用相同的ZIP文件重新上传
- Maven Central应该能够找到公钥并验证签名

## 📞 故障排除

### 如果上传失败
1. **检查网络连接**
2. **尝试不同的PGP服务器**
3. **等待几分钟后重试**

### 如果Maven Central仍然找不到公钥
1. **等待更长时间**（最多24小时）
2. **尝试上传到更多PGP服务器**
3. **联系Sonatype支持团队**

## ✅ 预期结果

上传公钥后，Maven Central应该能够：
- ✅ 找到公钥
- ✅ 验证签名
- ✅ 通过所有验证
- ✅ 成功发布到Maven Central

---

**注意**: 一旦公钥上传成功，你就可以使用相同的ZIP文件重新上传到Maven Central，应该能够成功通过验证！
