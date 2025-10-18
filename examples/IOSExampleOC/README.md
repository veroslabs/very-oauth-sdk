# VeryOauthSDK iOS Objective-C Example

这是一个使用 Objective-C 语言开发的 iOS 示例项目，演示如何使用 VeryOauthSDK 进行 OAuth 认证。

## 📱 项目特性

- **Objective-C 实现**：使用纯 Objective-C 语言开发
- **CocoaPods 集成**：通过 CocoaPods 管理依赖
- **双认证模式**：支持系统浏览器和 WebView 两种认证方式
- **完整 UI**：包含完整的用户界面和交互逻辑
- **错误处理**：完善的错误处理和用户反馈

## 🚀 快速开始

### 1. 环境要求

- iOS 12.0+
- Xcode 12.0+
- CocoaPods 1.10+

### 2. 安装依赖

```bash
cd examples/IOSExampleOC
pod install
```

### 3. 打开项目

```bash
open IOSExampleOC.xcworkspace
```

### 4. 配置 OAuth 参数

在 `ViewController.m` 中修改 OAuth 配置：

```objc
OAuthConfig *config = [[OAuthConfig alloc] initWithClientId:@"your_client_id"
                                               redirectUri:@"your_redirect_uri"
                                         authorizationUrl:@"your_authorization_url"
                                                   scope:@"your_scope"
                                       authenticationMode:mode
                                                  userId:@"your_user_id"];
```

## 🎯 功能演示

### 系统浏览器认证

1. 点击 "System Browser Authentication" 按钮
2. 系统会打开 Safari 浏览器进行认证
3. 认证完成后自动返回应用

### WebView 认证

1. 点击 "WebView Authentication" 按钮
2. 在应用内 WebView 中进行认证
3. 支持相机权限请求（用于二维码扫描等功能）

## 📋 项目结构

```
IOSExampleOC/
├── IOSExampleOC/
│   ├── AppDelegate.h/m          # 应用委托
│   ├── SceneDelegate.h/m       # 场景委托
│   ├── ViewController.h/m       # 主视图控制器
│   ├── Info.plist              # 应用配置
│   └── Assets.xcassets/        # 资源文件
├── Podfile                     # CocoaPods配置
├── Podfile.lock               # 依赖锁定文件
└── README.md                  # 项目说明
```

## 🔧 核心代码

### 导入 SDK

```objc
#import "VeryOauthSDK/VeryOauthSDK-Swift.h"
```

### 创建 OAuth 配置

```objc
OAuthConfig *config = [[OAuthConfig alloc] initWithClientId:@"client_id"
                                               redirectUri:@"redirect_uri"
                                         authorizationUrl:@"authorization_url"
                                                   scope:@"scope"
                                       authenticationMode:AuthenticationModeSystemBrowser
                                                  userId:@"user_id"];
```

### 开始认证

```objc
VeryOauthSDK *sdk = [VeryOauthSDK shared];
[sdk authenticateWithConfig:config
    presentingViewController:self
                   callback:^(OAuthResult * _Nonnull result) {
    // 处理认证结果
}];
```

### 处理认证结果

```objc
- (void)handleAuthenticationResult:(OAuthResult *)result {
    if ([result isKindOfClass:[OAuthResultSuccess class]]) {
        OAuthResultSuccess *success = (OAuthResultSuccess *)result;
        // 认证成功，获取token
        NSString *token = success.token;
    } else if ([result isKindOfClass:[OAuthResultFailure class]]) {
        OAuthResultFailure *failure = (OAuthResultFailure *)result;
        // 认证失败，处理错误
    } else if ([result isKindOfClass:[OAuthResultCancelled class]]) {
        // 用户取消认证
    }
}
```

## 🎨 UI 特性

- **响应式布局**：支持不同屏幕尺寸
- **加载指示器**：认证过程中显示加载动画
- **结果展示**：清晰显示认证结果
- **按钮状态**：认证过程中禁用按钮防止重复操作

## 📱 权限配置

在 `Info.plist` 中配置了必要的权限：

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for WebView authentication features.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for WebView authentication features.</string>
```

## 🔗 URL Scheme 配置

配置了回调 URL 处理：

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>VeryOauthSDK Callback</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>https</string>
        </array>
    </dict>
</array>
```

## 🐛 故障排除

### 常见问题

1. **编译错误**：确保使用 `.xcworkspace` 文件打开项目
2. **依赖问题**：运行 `pod install` 更新依赖
3. **权限问题**：检查 Info.plist 中的权限配置
4. **回调问题**：确保 URL Scheme 配置正确

### 调试技巧

- 查看控制台输出获取详细错误信息
- 检查网络连接和 OAuth 服务器状态
- 验证 OAuth 配置参数的正确性

## 📚 相关文档

- [VeryOauthSDK iOS 文档](../../ios/README.md)
- [CocoaPods 使用指南](https://guides.cocoapods.org/)
- [OAuth 2.0 规范](https://tools.ietf.org/html/rfc6749)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个示例项目。

## 📄 许可证

本项目使用 MIT 许可证。详见 [LICENSE](../../LICENSE) 文件。
