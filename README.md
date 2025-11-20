# VeryOauthSDK

[![iOS](https://img.shields.io/badge/iOS-12.0+-blue.svg)](https://developer.apple.com/ios/)
[![Android](https://img.shields.io/badge/Android-23+-green.svg)](https://developer.android.com/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.1+-purple.svg)](https://kotlinlang.org/)

VeryOauthSDK is an OAuth authentication SDK for iOS and Android applications. It provides easy-to-use APIs for palm biometric based OAuth 2.0 authentication.

This document first presents the integration APIs, followed by a description of a typical authentication workflow that demonstrates their use.

## Integration APIs

### iOS Integration

#### CocoaPods

```ruby
# Podfile
pod 'VeryOauthSDK', '~> 1.0.15'
```

#### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/veroslabs/very-oauth-sdk.git", from: "1.0.15")
]
```

#### Usage

```swift
import VeryOauthSDK

let config = OAuthConfig(
    clientId: "your_client_id",
    redirectUri: "your_redirect_uri",
    userId: "user_id", // empty string for registration, valid user_id string for verification
    themeMode: "dark" // dark or light
)

VeryOauthSDK().authenticate(
    config: config,
    presentingViewController: self
) { result in
    if result.isSuccess {
        print("Authentication successful: \(result.code)")
    } else {
        print("Authentication failed: \(result.error)")
    }
}
```

### Android Integration

#### Maven Central

```gradle
// build.gradle (Module: app)
dependencies {
    implementation 'org.very:veryoauthsdk:1.0.15'
}
```

#### Usage

```kotlin
import com.veryoauthsdk.*

val config = OAuthConfig(
    clientId = "your_client_id",
    redirectUri = "your_redirect_uri",
    userId = "user_id" // empty string for registration, valid user_id string for verification
)

VeryOauthSDK.getInstance().authenticate(
    context = context,
    config = config,
    callback = { result ->
        if (result.isSuccess) {
            println("Authentication successful: ${result.code}")
        } else {
            val errorMessage = when (result.error) {
                OAuthErrorType.USER_CANCELED -> "User cancelled authentication"
                OAuthErrorType.VERIFICATION_FAILED -> "Verification failed"
                OAuthErrorType.REGISTRATION_FAILED -> "Registration failed"
                OAuthErrorType.TIMEOUT -> "Request timeout"
                OAuthErrorType.NETWORK_ERROR -> "Network error"
                else -> "Unknown error occurred"
            }
            println("Authentication failed: $errorMessage")
        }
    }
)

```

### OAuthConfig Parameters

| Parameter     | Type   | Description                                                                               |
| ------------- | ------ | ----------------------------------------------------------------------------------------- |
| `clientId`    | String | The OAuth client ID assigned to your application.                                         |
| `redirectUri` | String | The OAuth redirect URI registered for your application.                                   |
| `userId`      | String | For enrollment, use an empty string. For verification, use the `external_user_id` string. |
| `themeMode`   | String | Supports dark or light mode (default: dark).                                              |

Before integration, please contact **[support@very.org](mailto:support@very.org)** to obtain your `client_id`, `client_secret`, and to register your `redirectUri`.
The `client_id` and `redirectUri` must be provided to the SDK, while the `client_secret` should be securely configured on your backend OAuth server.

The `userId` serves as the unique identifier for each user. To register a new user, pass an empty string. Upon successful registration, the SDK returns the newly created `userId` in the authentication result (see below). Store this `userId` in your user database for future verifications.
To verify an existing user, pass the corresponding `userId` of that user to the SDK.

### Authentication Result

| Response    | Type   | Description                                                                                                           |
| ----------- | ------ | --------------------------------------------------------------------------------------------------------------------- |
| `isSuccess` | bool   | Indicates whether the authentication was successful.                                                                  |
| `code`      | String | The authorization code returned in the callback. Used by the backend to obtain the final token from the OAuth server. |
| `error`     | enum   | The error type, if the authentication process fails.                                                                  |

If authentication succeeds, the SDK returns a `code` string to the app. The app must forward this `code` to your backend server, which will then exchange it for the final `id_token` from the Very OAuth endpoint. Details of this process are described in the **Authentication Workflow** section below.

If authentication fails, the SDK returns an `error` to the app. Possible error types include:

- **`UserCanceled`** – The user canceled the authentication process.
- **`VerificationFailed`** – The palm scan did not match the registered user.
- **`RegistrationFailed`** – The palm registration was identified as a potential fraud attempt.
- **`Timeout`** – The authentication request timed out.
- **`NetworkError`** – A network connectivity issue occurred.
- **`CameraPermissionDenied`** – The user has not granted camera permissions.

## Authentication Workflow

### Step 1. Call SDK to Obtain Authorization Code

The app configures the `OAuthConfig` parameters and calls the `authenticate` method as described in the **Usage** section above.
If authentication succeeds, the SDK returns a `code` string. Otherwise, it returns an `error`.

### Step 2. Exchange Authorization Code for ID Token

The app sends the `code` to your backend server.
Your backend then exchanges the `code` for tokens by making a **POST** request to the following endpoint:

**Endpoint:**
`POST https://api.very.org/oauth2/token`

**Content-Type:**
`application/x-www-form-urlencoded`

**Request Parameters:**

- `grant_type=authorization_code`
- `client_id` — Your app’s client ID
- `client_secret` — Your app’s client secret
- `code` — The authorization code returned from the SDK
- `redirect_uri` — The same redirect URI used in the initial authorization request

**Example Success Response (200):**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "openid",
  "id_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Token Details:**

- `access_token` — JWT used for API access (expires in 1 hour). Not used in this sdk authorization workflow.
- `id_token` — OIDC identity token (JWT) containing the user’s `external_user_id` in the `sub` claim.

---

### Step 3. Verify ID Token

Your backend decodes the JWT `id_token` to verify the user information, especially the `external_user_id` field, which contains the user’s unique identifier.

- For **registration**, store the `external_user_id` of the newly registered user.
- For **verification**, match the `external_user_id` with the user being verified.

**Example `id_token`:**

```json
{
  "iss": "https://connect.very.org",
  "sub": "vu-1ed0a927-a336-45dd-9c73-20092db9ae8d",
  "aud": ["veros_145b3a8f2a8f4dc59394cbbd0dd2a77f"],
  "exp": 1761013475,
  "nbf": 1761009875,
  "iat": 1761009875,
  "jti": "id_1761009875",
  "external_user_id": "vu-1ed0a927-a336-45dd-9c73-20092db9ae8d",
  "client_id": "veros_145b3a8f2a8f4dc59394cbbd0dd2a77f",
  "token_type": "id_token",
  "scope": "openid"
}
```

## Requirements

### iOS

- iOS 12.0+
- Swift 5.0+
- Xcode 12.0+

### Android

- Android API 23+ (Android 7.0)
- Kotlin 1.8+
- Android Studio 4.0+

## Setup

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
import com.veryoauthsdk.*
```

## Example Projects

### iOS Example

- **Location**: `examples/IOSExample/`
- **Features**: SwiftUI interface, dual authentication modes
- **Run**: Open `IOSExample.xcodeproj` in Xcode

### Android Example

- **Location**: `examples/AndroidExample/`
- **Features**: Jetpack Compose UI, dual authentication modes
- **Run**: `./gradlew assembleDebug`
