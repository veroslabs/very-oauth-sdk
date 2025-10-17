# VeryOauthSDK for iOS

[![iOS](https://img.shields.io/badge/iOS-12.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-1.0.0-green.svg)](https://cocoapods.org/)
[![SPM](https://img.shields.io/badge/SPM-Supported-purple.svg)](https://swift.org/package-manager/)

A modern OAuth authentication SDK for iOS applications with support for both system browser and in-app WebView authentication.

## 🚀 Installation

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'VeryOauthSDK', '~> 1.0.0'
```

Then run:

```bash
pod install
```

### Swift Package Manager

Add the package dependency in Xcode:

1. File → Add Package Dependencies
2. Enter repository URL: `https://github.com/veroslabs/very-oauth-sdk.git`
3. Select version: `1.0.0`
4. Add to your target

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/veroslabs/very-oauth-sdk.git", from: "1.0.0")
]
```

## 📱 Features

- **🔐 OAuth 2.0 Authentication**: Complete OAuth 2.0 flow implementation
- **🌐 Dual Authentication Modes**:
  - **System Browser**: Uses `ASWebAuthenticationSession` for secure authentication
  - **In-App Browser**: Uses `WKWebView` for in-app authentication
- **📷 Camera Support**: Camera permission handling for WebView mode
- **🎨 Modern Swift API**: Clean, type-safe Swift APIs
- **📚 Complete Documentation**: Comprehensive API documentation
- **🔒 Security**: Secure authentication with proper error handling

## 🛠️ Setup

### 1. Add Camera Permission

Add to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for WebView authentication features.</string>
```

### 2. Import the SDK

```swift
import VeryOauthSDK
```

## 🎯 Quick Start

### Basic Usage

```swift
import VeryOauthSDK

class ViewController: UIViewController {

    func startAuthentication() {
        let config = OAuthConfig(
            clientId: "your_client_id",
            redirectUri: "your_redirect_uri",
            authorizationUrl: "https://your-auth-server.com/oauth/authorize",
            scope: "openid",
            authenticationMode: .systemBrowser,
            userId: "optional_user_id"
        )

        VeryOauthSDK.shared.authenticate(
            config: config,
            presentingViewController: self
        ) { result in
            DispatchQueue.main.async {
                self.handleAuthenticationResult(result)
            }
        }
    }

    private func handleAuthenticationResult(_ result: OAuthResult) {
        switch result {
        case .success(let token, let state):
            print("✅ Authentication successful!")
            print("Token: \(token)")
            print("State: \(state ?? "N/A")")
            // Handle successful authentication

        case .failure(let error):
            print("❌ Authentication failed: \(error)")
            // Handle authentication error

        case .cancelled:
            print("⚠️ Authentication cancelled by user")
            // Handle user cancellation
        }
    }
}
```

### Authentication Modes

#### System Browser Mode (Recommended)

```swift
let config = OAuthConfig(
    clientId: "your_client_id",
    redirectUri: "your_redirect_uri",
    authorizationUrl: "https://your-auth-server.com/oauth/authorize",
    authenticationMode: .systemBrowser  // Uses ASWebAuthenticationSession
)
```

**Benefits:**

- More secure (uses system browser)
- Better user experience
- Automatic credential management
- Supports biometric authentication

#### In-App Browser Mode

```swift
let config = OAuthConfig(
    clientId: "your_client_id",
    redirectUri: "your_redirect_uri",
    authorizationUrl: "https://your-auth-server.com/oauth/authorize",
    authenticationMode: .webview  // Uses WKWebView
)
```

**Benefits:**

- Stays within your app
- Full control over UI
- Camera permission support
- Customizable user experience

## 📚 API Reference

### VeryOauthSDK

The main SDK class for OAuth authentication.

```swift
class VeryOauthSDK {
    /// Shared singleton instance
    static let shared: VeryOauthSDK

    /// Start OAuth authentication flow
    /// - Parameters:
    ///   - config: OAuth configuration
    ///   - presentingViewController: The view controller to present the authentication from
    ///   - callback: Completion handler with OAuth result
    func authenticate(
        config: OAuthConfig,
        presentingViewController: UIViewController,
        callback: @escaping (OAuthResult) -> Void
    )

    /// Cancel current authentication session
    func cancelAuthentication()
}
```

### OAuthConfig

Configuration class for OAuth authentication.

```swift
class OAuthConfig {
    let clientId: String
    let redirectUri: String
    let authorizationUrl: String
    let scope: String?
    let authenticationMode: AuthenticationMode
    let userId: String?

    init(
        clientId: String,
        redirectUri: String,
        authorizationUrl: String,
        scope: String? = "openid",
        authenticationMode: AuthenticationMode = .systemBrowser,
        userId: String? = nil
    )
}
```

### AuthenticationMode

Enum for authentication modes.

```swift
enum AuthenticationMode: Int, CaseIterable {
    case systemBrowser = 0  // Use system browser (ASWebAuthenticationSession)
    case webview = 1        // Use in-app browser (WKWebView)
}
```

### OAuthResult

Result class for authentication outcomes.

```swift
class OAuthResult {
    /// Successful authentication
    class Success: OAuthResult {
        let token: String      // Access token
        let state: String?     // OAuth state parameter
    }

    /// Authentication failed
    class Failure: OAuthResult {
        let error: Error       // Error details
    }

    /// User cancelled authentication
    class Cancelled: OAuthResult
}
```

### OAuthError

Error types for authentication failures.

```swift
enum OAuthError: Error, LocalizedError {
    case invalidRedirectUri      // Invalid redirect URI
    case authenticationFailed    // Authentication failed
    case userCancelled          // User cancelled
    case networkError(Error)     // Network error
}
```

## 🔧 Advanced Usage

### Custom Error Handling

```swift
VeryOauthSDK.shared.authenticate(
    config: config,
    presentingViewController: self
) { result in
    switch result {
    case .success(let token, let state):
        // Handle success
        self.processAuthenticationSuccess(token: token, state: state)

    case .failure(let error):
        // Handle different error types
        if let oauthError = error as? OAuthError {
            switch oauthError {
            case .invalidRedirectUri:
                self.showAlert(title: "Configuration Error",
                              message: "Invalid redirect URI")
            case .authenticationFailed:
                self.showAlert(title: "Authentication Failed",
                              message: "Please try again")
            case .userCancelled:
                // User cancelled, no action needed
                break
            case .networkError(let networkError):
                self.showAlert(title: "Network Error",
                              message: networkError.localizedDescription)
            }
        }

    case .cancelled:
        // User cancelled authentication
        break
    }
}
```

### Cancelling Authentication

```swift
// Cancel current authentication session
VeryOauthSDK.shared.cancelAuthentication()
```

### Objective-C Support

The SDK is fully compatible with Objective-C projects:

```objc
// Objective-C usage
OAuthConfig *config = [[OAuthConfig alloc]
    initWithClientId:@"your_client_id"
    redirectUri:@"your_redirect_uri"
    authorizationUrl:@"https://your-auth-server.com/oauth/authorize"
    scope:@"openid"
    authenticationMode:AuthenticationModeSystemBrowser
    userId:@"optional_user_id"];

[VeryOauthSDK.shared authenticateWithConfig:config
                    presentingViewController:self
                                  callback:^(OAuthResult *result) {
    if ([result isKindOfClass:[OAuthResultSuccess class]]) {
        OAuthResultSuccess *success = (OAuthResultSuccess *)result;
        NSLog(@"Token: %@", success.token);
    }
}];
```

## 🧪 Example Project

Check out the complete example project:

- **Location**: `examples/IOSExample/`
- **Features**: SwiftUI interface, dual authentication modes
- **Run**: Open `IOSExample.xcodeproj` in Xcode

### Example Features

- **SwiftUI Interface**: Modern, responsive UI
- **Dual Authentication Modes**: Switch between system browser and WebView
- **Real-time Status**: Live authentication status updates
- **Error Handling**: Comprehensive error handling examples
- **Camera Permission**: WebView camera permission handling

## 🔒 Security Features

- **Secure Storage**: Credentials stored securely in Keychain
- **HTTPS Only**: All network requests use HTTPS
- **State Validation**: OAuth state parameter validation
- **Error Handling**: Comprehensive error handling
- **Permission Management**: Proper camera permission handling

## 📋 Requirements

- **iOS**: 12.0+
- **Swift**: 5.0+
- **Xcode**: 12.0+
- **Deployment Target**: iOS 12.0+

## 🐛 Troubleshooting

### Common Issues

#### Camera Permission

Ensure `NSCameraUsageDescription` is added to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for WebView authentication features.</string>
```

#### URL Scheme

Verify your redirect URI matches your app's URL scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.yourapp.oauth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yourapp</string>
        </array>
    </dict>
</array>
```

#### iOS Version

The SDK requires iOS 12.0+ for `ASWebAuthenticationSession` support.

### Debug Tips

1. **Enable Logging**: Check Xcode console for detailed logs
2. **Test Both Modes**: Test both system browser and WebView modes
3. **Verify Configuration**: Ensure all OAuth parameters are correct
4. **Check Permissions**: Verify camera permission is granted

## 📞 Support

- **Documentation**: [https://very-sdk-docs.vercel.app/ios](https://very-sdk-docs.vercel.app/ios)
- **Issues**: [GitHub Issues](https://github.com/veroslabs/very-oauth-sdk/issues)
- **Email**: support@very.org

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.

---

**VeryOauthSDK for iOS** - Making OAuth authentication simple and secure on iOS.
