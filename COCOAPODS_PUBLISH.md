# CocoaPods 发布指南

## 🎯 目标

让开发者可以在 Podfile 中直接使用 `pod 'VeryOauthSDK'` 而不需要指定 Git 路径。

## 📋 发布步骤

### 1. 验证 CocoaPods Trunk 账户

```bash
# 注册账户（如果还没有）
pod trunk register support@very.org "VeryOauthSDK Team" --description="VeryOauthSDK OAuth authentication SDK"

# 检查注册状态
pod trunk me
```

**重要**：需要检查 `support@very.org` 邮箱，点击验证链接来激活账户。

### 2. 发布到 CocoaPods Trunk

```bash
# 验证邮箱后，发布podspec
pod trunk push VeryOauthSDK.podspec
```

### 3. 更新 Podfile

发布成功后，Podfile 可以简化为：

```ruby
platform :ios, '12.0'

target 'YourTarget' do
  use_frameworks!
  pod 'VeryOauthSDK'  # 不需要指定Git路径
end
```

## 🔄 版本更新流程

### 发布新版本

1. **更新版本号**：

   ```bash
   # 编辑 VeryOauthSDK.podspec，更新 spec.version
   spec.version = "1.1.0"
   ```

2. **创建 Git 标签**：

   ```bash
   git tag 1.1.0
   git push origin 1.1.0
   ```

3. **发布到 CocoaPods**：
   ```bash
   pod trunk push VeryOauthSDK.podspec
   ```

## 📦 当前状态

- ✅ **Git 仓库配置**：SDK 已配置为从 Git 仓库安装
- ✅ **Podspec 验证**：`pod spec lint` 通过
- ✅ **CocoaPods Trunk**：已成功发布到 CocoaPods Trunk
- ✅ **版本管理**：使用 Git 标签进行版本控制
- ⏳ **同步等待**：CocoaPods 搜索索引同步中（通常需要几分钟到几小时）

## 🚀 使用方式

### 当前方式（Git 仓库）

```ruby
pod 'VeryOauthSDK', :git => 'https://github.com/veroslabs/very-oauth-sdk.git', :tag => '1.0.0'
```

### 发布后方式（CocoaPods Trunk）

```ruby
pod 'VeryOauthSDK'
```

## 📝 注意事项

1. **邮箱验证**：必须验证 CocoaPods Trunk 注册邮箱
2. **版本冲突**：确保版本号唯一
3. **Git 标签**：每次发布前确保 Git 标签存在
4. **测试**：发布前使用 `pod spec lint` 验证

## 🔗 相关链接

- [CocoaPods Trunk 文档](https://guides.cocoapods.org/making/getting-setup-with-trunk.html)
- [Podspec 规范](https://guides.cocoapods.org/syntax/podspec.html)
