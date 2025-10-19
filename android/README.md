# VeryOauthSDK for Android

[![Android](https://img.shields.io/badge/Android-24+-green.svg)](https://developer.android.com/)
[![Kotlin](https://img.shields.io/badge/Kotlin-1.8+-purple.svg)](https://kotlinlang.org/)
[![Maven Central](https://img.shields.io/badge/Maven%20Central-1.0.2-blue.svg)](https://search.maven.org/)
[![JitPack](https://img.shields.io/badge/JitPack-1.0.2-orange.svg)](https://jitpack.io/)

A modern OAuth authentication SDK for Android applications with support for both Custom Tabs and WebView authentication.

## 🚀 Installation

### Maven Central

Add to your `build.gradle` (Module: app):

```gradle
dependencies {
       implementation 'org.very:veryoauthsdk:1.0.2'
}
```

**Note**: The library will be available on Maven Central after the first release. For now, you can use JitPack or build from source.

### JitPack

Add to your `build.gradle` (Project):

```gradle
allprojects {
    repositories {
        maven { url 'https://jitpack.io' }
    }
}
```

Add to your `build.gradle` (Module: app):

```gradle
dependencies {
       implementation 'com.github.veroslabs.very-oauth-sdk:1.0.2'
}
```

## 📱 Features

- **🔐 OAuth 2.0 Authentication**: Complete OAuth 2.0 flow implementation
- **🌐 Dual Authentication Modes**:
  - **System Browser**: Uses Chrome Custom Tabs for seamless browser experience
  - **In-App Browser**: Uses WebView for in-app authentication
- **📷 Camera Support**: Camera permission handling for WebView mode
- **🌍 Multi-Language Support**: Built-in support for 10+ languages
- **🎨 Modern Kotlin API**: Clean, type-safe Kotlin APIs
- **📚 Complete Documentation**: Comprehensive API documentation
- **🔒 Security**: Secure authentication with proper error handling

## 🛠️ Setup

### 1. Add Permissions

Add to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
```

### 2. Add Activity Declaration

Add to your `AndroidManifest.xml`:

```xml
<activity
    android:name="com.verysdk.OAuthActivity"
    android:theme="@style/Theme.AppCompat.Light.DarkActionBar"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="yourapp" />
    </intent-filter>
</activity>
```

### 3. Import the SDK

```kotlin
import com.verysdk.*
```

## 🎯 Quick Start

### Basic Usage

```kotlin
import com.verysdk.*

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        startAuthentication()
    }

    private fun startAuthentication() {
        val config = OAuthConfig(
            clientId = "your_client_id",
            redirectUri = "your_redirect_uri",
            authorizationUrl = "https://connect.very.org/oauth/authorize",
            scope = "openid",
            authenticationMode = AuthenticationMode.SYSTEM_BROWSER,
            userId = "optional_user_id"
        )

        VeryOauthSDK.getInstance().authenticate(
            context = this,
            config = config
        ) { result ->
            runOnUiThread {
                handleAuthenticationResult(result)
            }
        }
    }

    private fun handleAuthenticationResult(result: OAuthResult) {
        when (result) {
            is OAuthResult.Success -> {
                println("✅ Authentication successful!")
                println("Token: ${result.token}")
                println("State: ${result.state ?: "N/A"}")
                // Handle successful authentication
            }
            is OAuthResult.Failure -> {
                println("❌ Authentication failed: ${result.error}")
                // Handle authentication error
            }
            is OAuthResult.Cancelled -> {
                println("⚠️ Authentication cancelled by user")
                // Handle user cancellation
            }
        }
    }
}
```

### Authentication Modes

#### System Browser Mode (Recommended)

```kotlin
val config = OAuthConfig(
    clientId = "your_client_id",
    redirectUri = "your_redirect_uri",
    authorizationUrl = "https://connect.very.org/oauth/authorize",
    authenticationMode = AuthenticationMode.SYSTEM_BROWSER  // Uses Custom Tabs
)
```

**Benefits:**

- More secure (uses system browser)
- Better user experience
- Automatic credential management
- Supports biometric authentication

#### In-App Browser Mode

```kotlin
val config = OAuthConfig(
    clientId = "your_client_id",
    redirectUri = "your_redirect_uri",
    // authorizationUrl is optional, defaults to "https://connect.very.org/oauth/authorize"
    authenticationMode = AuthenticationMode.WEBVIEW  // Uses WebView
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

```kotlin
class VeryOauthSDK {
    companion object {
        @JvmStatic
        fun getInstance(): VeryOauthSDK
    }

    /**
     * Start OAuth authentication flow
     * @param context Application context
     * @param config OAuth configuration
     * @param callback Result callback
     */
    fun authenticate(
        context: Context,
        config: OAuthConfig,
        callback: (OAuthResult) -> Unit
    )

    /**
     * Set the language for the SDK
     * @param language The language to set
     */
    fun setLanguage(language: Language)

    /**
     * Get the current language
     * @return Current language
     */
    fun getCurrentLanguage(): Language
}
```

### OAuthConfig

Configuration class for OAuth authentication.

```kotlin
class OAuthConfig @JvmOverloads constructor(
    val clientId: String,
    val redirectUri: String,
    val authorizationUrl: String = "https://connect.very.org/oauth/authorize",
    val scope: String? = null,
    val authenticationMode: AuthenticationMode = AuthenticationMode.SYSTEM_BROWSER,
    val userId: String? = null
)
```

### AuthenticationMode

Enum for authentication modes.

```kotlin
enum class AuthenticationMode {
    SYSTEM_BROWSER,    // Use system browser (Custom Tabs)
    WEBVIEW            // Use in-app browser (WebView)
}
```

### OAuthResult

Sealed class for authentication outcomes.

```kotlin
sealed class OAuthResult {
    data class Success(val token: String, val state: String?) : OAuthResult()
    data class Failure(val error: Throwable) : OAuthResult()
    object Cancelled : OAuthResult()
}
```

### OAuthError

Error types for authentication failures.

```kotlin
sealed class OAuthError : Exception() {
    object InvalidRedirectUri : OAuthError()
    object AuthenticationFailed : OAuthError()
    object UserCancelled : OAuthError()
    data class NetworkError(val error: Throwable) : OAuthError()
}
```

### Language

Supported languages for the SDK.

```kotlin
enum class Language {
    ENGLISH,    // English (default)
    CHINESE,    // Chinese (Simplified)
    JAPANESE,   // Japanese
    KOREAN,     // Korean
    SPANISH,    // Spanish
    FRENCH,     // French
    GERMAN,     // German
    ITALIAN,    // Italian
    PORTUGUESE, // Portuguese
    RUSSIAN     // Russian
}
```

### LanguageManager

Language manager for handling localized strings.

```kotlin
object LanguageManager {
    fun setLanguage(language: Language)
    fun getCurrentLanguage(): Language
    fun getCameraPermissionTitle(): String
    fun getCameraPermissionMessage(): String
    fun getCameraPermissionDeniedTitle(): String
    fun getCameraPermissionDeniedMessage(): String
    fun getGrantPermissionButton(): String
    fun getContinueWithoutButton(): String
    fun getOkButton(): String
}
```

## 🔧 Advanced Usage

### Multi-Language Support

The SDK supports multiple languages for user-facing messages:

```kotlin
// Set language before authentication
VeryOauthSDK.getInstance().setLanguage(Language.CHINESE)

// Or set it globally
LanguageManager.setLanguage(Language.JAPANESE)

// Get current language
val currentLanguage = VeryOauthSDK.getInstance().getCurrentLanguage()

// Example with different languages
class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Set language based on user preference
        val userLanguage = getUserPreferredLanguage()
        VeryOauthSDK.getInstance().setLanguage(userLanguage)

        startAuthentication()
    }

    private fun getUserPreferredLanguage(): Language {
        // Get from SharedPreferences, system locale, etc.
        return when (Locale.getDefault().language) {
            "zh" -> Language.CHINESE
            "ja" -> Language.JAPANESE
            "ko" -> Language.KOREAN
            "es" -> Language.SPANISH
            "fr" -> Language.FRENCH
            "de" -> Language.GERMAN
            "it" -> Language.ITALIAN
            "pt" -> Language.PORTUGUESE
            "ru" -> Language.RUSSIAN
            else -> Language.ENGLISH
        }
    }
}
```

### Custom Error Handling

```kotlin
VeryOauthSDK.getInstance().authenticate(
    context = this,
    config = config
) { result ->
    when (result) {
        is OAuthResult.Success -> {
            // Handle success
            processAuthenticationSuccess(result.token, result.state)
        }
        is OAuthResult.Failure -> {
            // Handle different error types
            when (result.error) {
                is OAuthError.InvalidRedirectUri -> {
                    showAlert("Configuration Error", "Invalid redirect URI")
                }
                is OAuthError.AuthenticationFailed -> {
                    showAlert("Authentication Failed", "Please try again")
                }
                is OAuthError.UserCancelled -> {
                    // User cancelled, no action needed
                }
                is OAuthError.NetworkError -> {
                    showAlert("Network Error", result.error.error.message ?: "Unknown error")
                }
                else -> {
                    showAlert("Error", result.error.message ?: "Unknown error")
                }
            }
        }
        is OAuthResult.Cancelled -> {
            // User cancelled authentication
        }
    }
}
```

### Java Support

The SDK is fully compatible with Java projects:

```java
// Java usage
OAuthConfig config = new OAuthConfig(
    "your_client_id",
    "your_redirect_uri",
    "https://connect.very.org/oauth/authorize",
    "openid",
    AuthenticationMode.SYSTEM_BROWSER,
    "optional_user_id"
);

VeryOauthSDK.getInstance().authenticate(
    this,
    config,
    result -> {
        if (result instanceof OAuthResult.Success) {
            OAuthResult.Success success = (OAuthResult.Success) result;
            Log.d("Auth", "Token: " + success.getToken());
        }
    }
);
```

### Jetpack Compose Integration

```kotlin
@Composable
fun AuthenticationScreen() {
    var authResult by remember { mutableStateOf<String?>(null) }

    Button(
        onClick = {
            val config = OAuthConfig(
                clientId = "your_client_id",
                redirectUri = "your_redirect_uri",
                authorizationUrl = "https://connect.very.org/oauth/authorize"
            )

            VeryOauthSDK.getInstance().authenticate(
                context = LocalContext.current,
                config = config
            ) { result ->
                authResult = when (result) {
                    is OAuthResult.Success -> "Success: ${result.token}"
                    is OAuthResult.Failure -> "Failed: ${result.error.message}"
                    is OAuthResult.Cancelled -> "Cancelled"
                }
            }
        }
    ) {
        Text("Authenticate")
    }

    authResult?.let { result ->
        Text(result)
    }
}
```

## 🧪 Example Project

Check out the complete example project:

- **Location**: `examples/AndroidExample/`
- **Features**: Jetpack Compose UI, dual authentication modes
- **Run**: `./gradlew assembleDebug`

### Example Features

- **Jetpack Compose UI**: Modern, responsive UI
- **Dual Authentication Modes**: Switch between Custom Tabs and WebView
- **Real-time Status**: Live authentication status updates
- **Error Handling**: Comprehensive error handling examples
- **Camera Permission**: WebView camera permission handling

## 🔒 Security Features

- **Secure Storage**: Credentials stored securely
- **HTTPS Only**: All network requests use HTTPS
- **State Validation**: OAuth state parameter validation
- **Error Handling**: Comprehensive error handling
- **Permission Management**: Proper camera permission handling

## 📋 Requirements

- **Android**: API 24+ (Android 7.0)
- **Kotlin**: 1.8+
- **Android Studio**: 4.0+
- **Gradle**: 7.0+

## 🐛 Troubleshooting

### Common Issues

#### Permissions

Ensure required permissions are added to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
```

#### Theme Issues

Ensure AppCompat theme is used for OAuthActivity:

```xml
<activity
    android:name="com.verysdk.OAuthActivity"
    android:theme="@style/Theme.AppCompat.Light.DarkActionBar"
    android:exported="true">
</activity>
```

#### ProGuard Rules

Add ProGuard rules to prevent obfuscation:

```proguard
-keep class com.verysdk.** { *; }
-keep class com.verysdk.OAuthActivity { *; }
```

#### URL Scheme

Verify your redirect URI matches your app's URL scheme in the intent filter.

### Debug Tips

1. **Enable Logging**: Check Logcat for detailed logs
2. **Test Both Modes**: Test both Custom Tabs and WebView modes
3. **Verify Configuration**: Ensure all OAuth parameters are correct
4. **Check Permissions**: Verify camera permission is granted
5. **Test on Different Devices**: Test on various Android versions

## 📞 Support

- **Documentation**: [https://very-sdk-docs.vercel.app/android](https://very-sdk-docs.vercel.app/android)
- **Issues**: [GitHub Issues](https://github.com/veroslabs/very-oauth-sdk/issues)
- **Email**: support@very.org

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.

---

**VeryOauthSDK for Android** - Making OAuth authentication simple and secure on Android.
