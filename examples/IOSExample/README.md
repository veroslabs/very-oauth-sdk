# VeryOauthSDK iOS Example

A complete example application demonstrating VeryOauthSDK usage on iOS with SwiftUI interface and dual authentication modes.

## 🚀 Features

- **🎨 SwiftUI Interface**: Modern, responsive user interface
- **🔐 Dual Authentication Modes**:
  - System Browser (ASWebAuthenticationSession)
  - In-App Browser (WKWebView)
- **📷 Camera Permission**: WebView camera permission handling
- **📊 Real-time Status**: Live authentication status updates
- **🛠️ Error Handling**: Comprehensive error handling examples
- **📱 iOS 12.0+ Support**: Compatible with iOS 12.0 and later

## 📋 Requirements

- **iOS**: 12.0+
- **Swift**: 5.0+
- **Xcode**: 12.0+
- **VeryOauthSDK**: 1.0.0+

## 🛠️ Setup

### 1. Clone the Repository

```bash
git clone https://github.com/veroslabs/very-oauth-sdk.git
cd very-sdk/examples/IOSExample
```

### 2. Open in Xcode

```bash
open IOSExample.xcodeproj
```

### 3. Configure OAuth Settings

Update the OAuth configuration in `ContentView.swift`:

```swift
let config = OAuthConfig(
    clientId: "your_client_id",                    // Replace with your client ID
    redirectUri: "your_redirect_uri",              // Replace with your redirect URI
    authorizationUrl: "https://connect.very.org/oauth/authorize", // Replace with your auth URL
    scope: "openid",
    authenticationMode: selectedProvider == "AuthenticationSession" ? .systemBrowser : .webview,
    userId: "optional_user_id"                     // Replace with your user ID
)
```

### 4. Configure URL Scheme

Add your app's URL scheme to `Info.plist`:

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

### 5. Add Camera Permission

The camera permission is already configured in `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for WebView authentication features.</string>
```

## 🎯 Running the Example

### 1. Build and Run

1. Open `IOSExample.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press `Cmd + R` to build and run

### 2. Test Authentication

1. **Select Authentication Mode**:

   - **Web Authentication Session**: Uses system browser
   - **WebView**: Uses in-app browser

2. **Start Authentication**:
   - Tap the "Start Authentication" button
   - Follow the OAuth flow
   - Observe the results

## 📱 Example Features

### SwiftUI Interface

The example uses SwiftUI for a modern, responsive interface:

```swift
struct ContentView: View {
    @State private var selectedProvider = "AuthenticationSession"
    @State private var isLoading = false
    @State private var authResult = ""
    @State private var resultColor = Color.blue

    private let sdk = VeryOauthSDK()

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Title and description
                // Provider selection
                // Authentication button
                // Results display
            }
        }
    }
}
```

### Dual Authentication Modes

#### System Browser Mode

```swift
let config = OAuthConfig(
    clientId: "your_client_id",
    redirectUri: "your_redirect_uri",
    authenticationMode: .systemBrowser  // Uses ASWebAuthenticationSession
)
```

#### In-App Browser Mode

```swift
let config = OAuthConfig(
    clientId: "your_client_id",
    redirectUri: "your_redirect_uri",
    authenticationMode: .webview  // Uses WKWebView
)
```

### Error Handling

The example demonstrates comprehensive error handling:

```swift
private func handleAuthenticationResult(_ result: OAuthResult) {
    switch result {
    case .success(let token, let state):
        authResult = "✅ Authentication successful!\n\nToken: \(token)\nState: \(state ?? "N/A")"
        resultColor = .green

    case .failure(let error):
        let errorMessage = error.localizedDescription
        authResult = "❌ Authentication failed: \(errorMessage)"
        resultColor = .red

    case .cancelled:
        authResult = "⚠️ Authentication cancelled by user"
        resultColor = .orange
    }
}
```

## 🔧 Configuration

### OAuth Configuration

Update the following parameters in `ContentView.swift`:

| Parameter          | Description                    | Example                                              |
| ------------------ | ------------------------------ | ---------------------------------------------------- |
| `clientId`         | Your OAuth client ID           | `"veros_145b3a8f2a8f4dc59394cbbd0dd2a77f"`           |
| `redirectUri`      | OAuth redirect URI             | `"https://veros-web-oauth-demo.vercel.app/callback"` |
| `authorizationUrl` | OAuth authorization server URL | `"https://connect.very.org/oauth/authorize"`         |
| `scope`            | OAuth scope                    | `"openid"`                                           |
| `userId`           | Optional user identifier       | `"vu-1ed0a927-a336-45dd-9c73-20092db9ae8d"`          |

### URL Scheme Configuration

Configure your app's URL scheme in `Info.plist`:

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

## 🧪 Testing

### Test Scenarios

1. **System Browser Authentication**:

   - Select "Web Authentication Session"
   - Tap "Start Authentication"
   - Verify system browser opens
   - Complete OAuth flow
   - Verify success callback

2. **WebView Authentication**:

   - Select "WebView"
   - Tap "Start Authentication"
   - Verify in-app browser opens
   - Complete OAuth flow
   - Verify success callback

3. **Error Handling**:

   - Test with invalid configuration
   - Test user cancellation
   - Test network errors

4. **Camera Permission**:
   - Test WebView mode
   - Verify camera permission request
   - Test with permission denied

### Debug Tips

1. **Enable Logging**: Check Xcode console for detailed logs
2. **Test Both Modes**: Ensure both authentication modes work
3. **Verify Configuration**: Check all OAuth parameters
4. **Test Permissions**: Verify camera permission handling

## 📚 Code Structure

```
IOSExample/
├── IOSExample/
│   ├── IOSExampleApp.swift          # App entry point
│   ├── ContentView.swift            # Main SwiftUI view
│   ├── VeryOauthSDK.swift          # SDK integration
│   └── Info.plist                   # App configuration
├── IOSExample.xcodeproj             # Xcode project
└── README.md                        # This file
```

### Key Files

- **`ContentView.swift`**: Main SwiftUI interface
- **`VeryOauthSDK.swift`**: SDK integration and usage
- **`Info.plist`**: App configuration and permissions
- **`IOSExampleApp.swift`**: App entry point

## 🔒 Security Considerations

- **HTTPS Only**: All OAuth requests use HTTPS
- **State Validation**: OAuth state parameter validation
- **Secure Storage**: Credentials stored securely
- **Permission Handling**: Proper camera permission management

## 🐛 Troubleshooting

### Common Issues

#### Build Errors

- Ensure iOS 12.0+ deployment target
- Verify Swift 5.0+ compatibility
- Check Xcode version compatibility

#### Runtime Errors

- Verify OAuth configuration
- Check URL scheme configuration
- Ensure proper permissions

#### Authentication Failures

- Verify client ID and redirect URI
- Check authorization server URL
- Ensure network connectivity

### Debug Steps

1. **Check Console Logs**: Look for error messages
2. **Verify Configuration**: Ensure all parameters are correct
3. **Test Network**: Verify internet connectivity
4. **Check Permissions**: Ensure camera permission is granted

## 📞 Support

- **Documentation**: [https://very-sdk-docs.vercel.app/ios](https://very-sdk-docs.vercel.app/ios)
- **Issues**: [GitHub Issues](https://github.com/veroslabs/very-oauth-sdk/issues)
- **Email**: support@very.org

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details.

---

**VeryOauthSDK iOS Example** - A complete example of OAuth authentication on iOS.
