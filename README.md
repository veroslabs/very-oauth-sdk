# VeryOauthSDK

[![iOS](https://img.shields.io/badge/iOS-12.0+-blue.svg)](https://developer.apple.com/ios/)
[![Android](https://img.shields.io/badge/Android-24+-green.svg)](https://developer.android.com/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![Kotlin](https://img.shields.io/badge/Kotlin-1.8+-purple.svg)](https://kotlinlang.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

VeryOauthSDK is a modern OAuth authentication SDK for iOS and Android applications. It provides easy-to-use APIs for OAuth 2.0 authentication with support for multiple authentication methods.

## ✨ Features

- **🔐 OAuth 2.0 Authentication**: Complete OAuth 2.0 flow implementation
- **📱 Dual Authentication Modes**:
  - iOS: ASWebAuthenticationSession / WKWebView
  - Android: Custom Tabs / WebView
- **📷 Camera Support**: Camera permission handling for WebView mode
- **🎨 Modern APIs**: Swift and Kotlin native APIs
- **📚 Complete Documentation**: API docs and usage examples
- **🧪 Example Apps**: Full-featured example applications
- **🌐 Cross-Platform**: Consistent API across iOS and Android
- **🔒 Security**: Secure authentication with proper error handling

## 🚀 Quick Start

### iOS Integration

#### CocoaPods

```ruby
# Podfile
pod 'VeryOauthSDK', '~> 1.0.0'
```

#### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/veroslabs/very-oauth-sdk.git", from: "1.0.0")
]
```

#### Usage

```swift
import VeryOauthSDK

let config = OAuthConfig(
    clientId: "your_client_id",
    redirectUri: "your_redirect_uri",
    authorizationUrl: "https://connect.very.org/oauth/authorize",
    scope: "openid",
    authenticationMode: .systemBrowser, // or .webview
    userId: "optional_user_id"
)

VeryOauthSDK.shared.authenticate(
    config: config,
    presentingViewController: self
) { result in
    switch result {
    case .success(let token, let state):
        print("Authentication successful: \(token)")
    case .failure(let error):
        print("Authentication failed: \(error)")
    case .cancelled:
        print("Authentication cancelled")
    }
}
```

### Android Integration

#### Maven Central

```gradle
// build.gradle (Module: app)
dependencies {
    implementation 'com.verysdk:veryoauthsdk:1.0.0'
}
```

#### JitPack

```gradle
// build.gradle (Project)
allprojects {
    repositories {
        maven { url 'https://jitpack.io' }
    }
}

// build.gradle (Module: app)
dependencies {
    implementation 'com.github.veroslabs.very-oauth-sdk:1.0.0'
}
```

#### Usage

```kotlin
import com.verysdk.*

val config = OAuthConfig(
    clientId = "your_client_id",
    redirectUri = "your_redirect_uri",
    authorizationUrl = "https://connect.very.org/oauth/authorize",
    scope = "openid",
    authenticationMode = AuthenticationMode.SYSTEM_BROWSER, // or AuthenticationMode.WEBVIEW
    userId = "optional_user_id"
)

VeryOauthSDK.getInstance().authenticate(
    context = this,
    config = config
) { result ->
    when (result) {
        is OAuthResult.Success -> {
            println("Authentication successful: ${result.token}")
        }
        is OAuthResult.Failure -> {
            println("Authentication failed: ${result.error}")
        }
        is OAuthResult.Cancelled -> {
            println("Authentication cancelled")
        }
    }
}
```

## 📱 Authentication Modes

### System Browser Mode

- **iOS**: Uses `ASWebAuthenticationSession` for secure system browser authentication
- **Android**: Uses Chrome Custom Tabs for seamless browser experience
- **Benefits**:
  - More secure (uses system browser)
  - Better user experience
  - Automatic credential management

### WebView Mode

- **iOS**: Uses `WKWebView` for in-app authentication
- **Android**: Uses `WebView` for in-app authentication
- **Benefits**:
  - Stays within your app
  - Full control over UI
  - Camera permission support

## 🔧 Configuration

### OAuthConfig Parameters

| Parameter            | Type               | Required | Description                     |
| -------------------- | ------------------ | -------- | ------------------------------- |
| `clientId`           | String             | ✅       | Your OAuth client ID            |
| `redirectUri`        | String             | ✅       | OAuth redirect URI              |
| `authorizationUrl`   | String             | ✅       | OAuth authorization server URL  |
| `scope`              | String             | ❌       | OAuth scope (default: "openid") |
| `authenticationMode` | AuthenticationMode | ❌       | Authentication method           |
| `userId`             | String             | ❌       | Optional user identifier        |

### AuthenticationMode Options

| Platform    | System Browser                      | WebView                      |
| ----------- | ----------------------------------- | ---------------------------- |
| **iOS**     | `.systemBrowser`                    | `.webview`                   |
| **Android** | `AuthenticationMode.SYSTEM_BROWSER` | `AuthenticationMode.WEBVIEW` |

## 📋 Requirements

### iOS

- iOS 12.0+
- Swift 5.0+
- Xcode 12.0+

### Android

- Android API 24+ (Android 7.0)
- Kotlin 1.8+
- Android Studio 4.0+

## 🛠️ Setup

### iOS Setup

1. **Add to Info.plist**

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for WebView authentication features.</string>
```

2. **Import and Use**

```swift
import VeryOauthSDK
```

### Android Setup

1. **Add Permissions to AndroidManifest.xml**

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
```

2. **Import and Use**

```kotlin
import com.verysdk.*
```

## 🎯 Example Projects

### iOS Example

- **Location**: `examples/IOSExample/`
- **Features**: SwiftUI interface, dual authentication modes
- **Run**: Open `IOSExample.xcodeproj` in Xcode

### Android Example

- **Location**: `examples/AndroidExample/`
- **Features**: Jetpack Compose UI, dual authentication modes
- **Run**: `./gradlew assembleDebug`

## 🔒 Security Features

- **Secure Storage**: Credentials stored securely
- **HTTPS Only**: All network requests use HTTPS
- **State Validation**: OAuth state parameter validation
- **Error Handling**: Comprehensive error handling
- **Permission Management**: Proper camera permission handling

## 📚 API Reference

### iOS API

#### VeryOauthSDK

```swift
class VeryOauthSDK {
    static let shared: VeryOauthSDK

    func authenticate(
        config: OAuthConfig,
        presentingViewController: UIViewController,
        callback: @escaping (OAuthResult) -> Void
    )

    func cancelAuthentication()
}
```

#### OAuthConfig

```swift
class OAuthConfig {
    let clientId: String
    let redirectUri: String
    let authorizationUrl: String
    let scope: String?
    let authenticationMode: AuthenticationMode
    let userId: String?
}
```

#### OAuthResult

```swift
class OAuthResult {
    class Success: OAuthResult {
        let token: String
        let state: String?
    }

    class Failure: OAuthResult {
        let error: Error
    }

    class Cancelled: OAuthResult
}
```

### Android API

#### VeryOauthSDK

```kotlin
class VeryOauthSDK {
    companion object {
        fun getInstance(): VeryOauthSDK
    }

    fun authenticate(
        context: Context,
        config: OAuthConfig,
        callback: (OAuthResult) -> Unit
    )
}
```

#### OAuthConfig

```kotlin
class OAuthConfig(
    val clientId: String,
    val redirectUri: String,
    val authorizationUrl: String,
    val scope: String? = null,
    val authenticationMode: AuthenticationMode = AuthenticationMode.SYSTEM_BROWSER,
    val userId: String? = null
)
```

#### OAuthResult

```kotlin
sealed class OAuthResult {
    data class Success(val token: String, val state: String?) : OAuthResult()
    data class Failure(val error: Throwable) : OAuthResult()
    object Cancelled : OAuthResult()
}
```

## 🐛 Troubleshooting

### Common Issues

#### iOS

- **Camera Permission**: Ensure `NSCameraUsageDescription` is added to Info.plist
- **URL Scheme**: Verify redirect URI matches your app's URL scheme
- **iOS Version**: Requires iOS 12.0+ for ASWebAuthenticationSession

#### Android

- **Permissions**: Add INTERNET and CAMERA permissions to AndroidManifest.xml
- **Theme**: Ensure AppCompat theme is used for OAuthActivity
- **ProGuard**: Add rules to prevent obfuscation of SDK classes

### Error Handling

```swift
// iOS
switch result {
case .failure(let error):
    if let oauthError = error as? OAuthError {
        switch oauthError {
        case .invalidRedirectUri:
            // Handle invalid redirect URI
        case .authenticationFailed:
            // Handle authentication failure
        case .userCancelled:
            // Handle user cancellation
        case .networkError(let error):
            // Handle network error
        }
    }
}
```

```kotlin
// Android
when (result) {
    is OAuthResult.Failure -> {
        when (result.error) {
            is OAuthError.InvalidRedirectUri -> {
                // Handle invalid redirect URI
            }
            is OAuthError.AuthenticationFailed -> {
                // Handle authentication failure
            }
            is OAuthError.UserCancelled -> {
                // Handle user cancellation
            }
            is OAuthError.NetworkError -> {
                // Handle network error
            }
        }
    }
}
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Documentation**: [https://very-sdk-docs.vercel.app](https://very-sdk-docs.vercel.app)
- **Issues**: [GitHub Issues](https://github.com/veroslabs/very-oauth-sdk/issues)
- **Email**: support@very.org

## 🔄 Changelog

### Version 1.0.0

- Initial release
- iOS and Android support
- Dual authentication modes
- Camera permission support
- Complete OAuth 2.0 implementation

---

**VeryOauthSDK** - Making OAuth authentication simple and secure across platforms.
