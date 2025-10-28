# Very OAuth SDK for Flutter

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![iOS](https://img.shields.io/badge/iOS-12.0+-blue.svg)](https://developer.apple.com/ios/)
[![Android](https://img.shields.io/badge/Android-24+-green.svg)](https://developer.android.com/)

Very OAuth SDK for Flutter is a cross-platform OAuth authentication plugin that provides easy-to-use APIs for palm biometric based OAuth 2.0 authentication on iOS and Android platforms.

This document presents the Flutter integration APIs, followed by a description of a typical authentication workflow.

## Installation

### pubspec.yaml

Add the following dependency to your `pubspec.yaml`:

```yaml
dependencies:
  very_oauth_sdk:
    git:
      url: https://github.com/veroslabs/very-oauth-sdk.git
      path: flutter
```

### iOS Setup

1. **Add to Info.plist**

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for WebView authentication features.</string>
```

2. **CocoaPods Integration**

The plugin automatically handles CocoaPods integration. Run:

```bash
cd ios && pod install
```

### Android Setup

1. **Add Permissions to AndroidManifest.xml**

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
```

2. **Gradle Configuration**

The plugin automatically handles Android configuration.

## Usage

### Basic Authentication

```dart
import 'package:very_oauth_sdk/very_oauth_sdk.dart';

// Create OAuth configuration
final config = OAuthConfig.minimal(
  clientId: "your_client_id",
  redirectUri: "your_redirect_uri",
  userId: "user_id", // empty string for registration, valid user_id string for verification
);

// Start authentication
try {
  final result = await VeryOauthSDK.authenticate(config);

  if (result.isSuccess) {
    // Send the code to your backend server
    print("Authentication successful: ${result.code}");
  } else {
    print("Authentication failed: ${result.error}");
  }
} catch (e) {
  print("Error: $e");
}
```

## OAuthConfig Parameters

| Parameter     | Type    | Description                                                                               |
| ------------- | ------- | ----------------------------------------------------------------------------------------- |
| `clientId`    | String  | The OAuth client ID assigned to your application. (Required)                              |
| `redirectUri` | String  | The OAuth redirect URI registered for your application. (Required)                        |
| `userId`      | String? | For enrollment, use an empty string. For verification, use the `external_user_id` string. |
|               |

### OAuthConfig Parameters

| Parameter     | Type   | Description                                                                               |
| ------------- | ------ | ----------------------------------------------------------------------------------------- |
| `clientId`    | String | The OAuth client ID assigned to your application.                                         |
| `redirectUri` | String | The OAuth redirect URI registered for your application.                                   |
| `userId`      | String | For enrollment, use an empty string. For verification, use the `external_user_id` string. |

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
