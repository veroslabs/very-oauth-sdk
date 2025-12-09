package com.veryoauthsdk

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.browser.customtabs.CustomTabsIntent
import androidx.core.content.ContextCompat
import kotlinx.coroutines.*
import java.net.HttpURLConnection
import java.net.URL
import org.json.JSONObject

/**
 * Authentication mode enum
 */
enum class BrowserMode {
    SYSTEM_BROWSER,    // Use system browser (Custom Tabs) - default
    WEBVIEW            // Use in-app browser (WebView)
}

/**
 * OAuth configuration class
 */
class OAuthConfig @JvmOverloads constructor(
    val clientId: String,
    val redirectUri: String,
    val authorizationUrl: String = "https://connect.very.org/oauth/authorize",
    var scope: String? = "openid",
    var browserMode: BrowserMode = BrowserMode.WEBVIEW,
    val userId: String? = null,
    var language: String? = null,
    var themeMode: String = "dark"
) {
    init {
        // Validate themeMode
        require(themeMode == "light" || themeMode == "dark") {
            "themeMode must be either 'light' or 'dark'"
        }
    }
}

/**
 * OAuth error types enum
 */
enum class OAuthErrorType(val value: Int) {
    SUCCESS(0),
    USER_CANCELED(1),
    VERIFICATION_FAILED(3),
    REGISTRATION_FAILED(4),
    TIMEOUT(5),
    NETWORK_ERROR(6),
    CAMERA_PERMISSION_DENIED(7),
    DEVICE_NOT_SUPPORT(8)
}

/**
 * OAuth result class
 */
data class OAuthResult(
    val code: String,
    val error: OAuthErrorType = OAuthErrorType.VERIFICATION_FAILED
) {
    val isSuccess: Boolean
        get() = error == OAuthErrorType.SUCCESS
}

/**
 * Main VeryOauthSDK class for OAuth authentication
 */
class VeryOauthSDK private constructor() {
    
    companion object {
        @Volatile
        private var INSTANCE: VeryOauthSDK? = null
        
        @Volatile
        private var configApiUrl: String? = "https://api.very.org/v1/sdk/config/web"
        
        @JvmStatic
        fun getInstance(): VeryOauthSDK {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: VeryOauthSDK().also { INSTANCE = it }
            }
        }
        
        /**
         * Set the API URL for fetching support configuration
         * @param url API endpoint URL
         */
        @JvmStatic
        fun setConfigApiUrl(url: String?) {
            configApiUrl = url
        }
        
        /**
         * Check if current device supports using this SDK
         * Checks Android version and memory requirements based on current configuration,
         * then asynchronously fetches and updates configuration from API
         * @param context Application context
         * @return true if device meets requirements, false otherwise
         */
        @JvmStatic
        fun isSupport(context: Context): Boolean {
            // First, check with current configuration and return immediately
            val config = SupportConfigManager.getConfig(context)
            
            // Check Android version (API level)
            val currentApiLevel = Build.VERSION.SDK_INT
            val isVersionSupported = currentApiLevel >= config.androidApiLevel
            
            // Check memory (RAM) requirement
            // Compare: deviceMemoryMB + 1000 >= config.androidMemory
            val deviceMemoryMB = getDeviceMemoryMB(context)
            // If memory cannot be determined (returns -1), skip memory check and allow
            // Only check memory requirement if we successfully retrieved the memory value
            val isMemorySupported = if (deviceMemoryMB == -1) {
                true // Cannot determine memory, allow device to pass
            } else {
                deviceMemoryMB + 1000 >= config.androidMemory
            }
            
            val isSupported = isVersionSupported && isMemorySupported
            
            // Fetch latest config in background for next time (regardless of result)
            fetchAndUpdateConfig(context)
            
            return isSupported
        }
        
        /**
         * Fetch support configuration from API and update local storage
         * This is called internally and runs asynchronously
         * @param context Application context
         */
        private fun fetchAndUpdateConfig(context: Context) {
            val apiUrl = configApiUrl ?: return
            
            // Use CoroutineScope to run async network request
            CoroutineScope(Dispatchers.IO).launch {
                try {
                    val url = URL(apiUrl)
                    val connection = url.openConnection() as HttpURLConnection
                    connection.requestMethod = "GET"
                    connection.connectTimeout = 5000 // 5 seconds timeout
                    connection.readTimeout = 5000
                    connection.setRequestProperty("Content-Type", "application/json")
                    
                    val responseCode = connection.responseCode
                    if (responseCode == HttpURLConnection.HTTP_OK) {
                        val response = connection.inputStream.bufferedReader().use { it.readText() }
                        
                        // Use optJSONObject for safer parsing
                        val jsonObject = JSONObject(response)
                        val minObject = jsonObject.optJSONObject("min")
                        
                        if (minObject != null) {
                            val configMap = mutableMapOf<String, Any>()
                            
                            // Parse androidApiLevel
                            val androidApiLevel = minObject.optInt("androidApiLevel", 0)
                            if (androidApiLevel > 0) {
                                configMap["androidApiLevel"] = androidApiLevel
                            }
                            // Also support legacy "androidVersion" key for backward compatibility
                            val androidVersion = minObject.optInt("androidVersion", 0)
                            if (androidVersion > 0) {
                                configMap["androidApiLevel"] = androidVersion
                            }
                            
                            // Parse androidMemory (keep in MB, no conversion needed)
                            val androidMemoryMB = minObject.optInt("androidMemory", 0)
                            if (androidMemoryMB > 0) {
                                configMap["androidMemory"] = androidMemoryMB
                            }
                            
                            if (configMap.isNotEmpty()) {
                                SupportConfigManager.updateConfigFromMap(context, configMap)
                            }
                        }
                    }
                    connection.disconnect()
                } catch (e: Exception) {
                    // Silently fail - network errors should not affect isSupport result
                    // Configuration will use cached values
                }
            }
        }
        
        /**
         * Get device total memory in MB
         * @param context Application context
         * @return Total memory in MB, or -1 if unable to determine (to distinguish from 0MB)
         */
        private fun getDeviceMemoryMB(context: Context): Int {
            return try {
                val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
                if (activityManager != null) {
                    val memInfo = ActivityManager.MemoryInfo()
                    activityManager.getMemoryInfo(memInfo)
                    
                    // totalMem is available from API 16+, and we require Android 10 (API 29)
                    // so this should always be available
                    val totalMemoryBytes = memInfo.totalMem
                    
                    if (totalMemoryBytes <= 0) {
                        // Invalid memory value, return -1 to indicate failure
                        return -1
                    }
                    
                    // Convert bytes to MB (1 MB = 1024 * 1024 bytes)
                    val memoryMB = totalMemoryBytes / (1024.0 * 1024.0)
                    memoryMB.toInt()
                } else {
                    -1
                }
            } catch (e: Exception) {
                // If unable to determine memory, return -1 (will skip memory check)
                -1
            }
        }
    }
    
    private var authCallback: ((OAuthResult) -> Unit)? = null
    private var customTabsIntent: CustomTabsIntent? = null
    
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
    ) {
        // Check if device supports this SDK
        if (!isSupport(context)) {
            callback(OAuthResult("", OAuthErrorType.DEVICE_NOT_SUPPORT))
            return
        }
        
        this.authCallback = callback
        
        try {
            val authUrl = buildAuthorizationUrl(config)
            
            when (config.browserMode) {
                BrowserMode.SYSTEM_BROWSER -> {
                    startCustomTabsAuthentication(context, authUrl, config)
                }
                BrowserMode.WEBVIEW -> {
                    startWebViewAuthentication(context, authUrl, config)
                }
            }
        } catch (e: Exception) {
            callback(OAuthResult("", OAuthErrorType.VERIFICATION_FAILED))
        }
    }
    
    /**
     * Handle OAuth result from activity
     */
    internal fun handleOAuthResult(result: OAuthResult) {
        authCallback?.invoke(result)
        authCallback = null
    }
    
    /**
     * Cancel current authentication
     */
    fun cancelAuthentication() {
        authCallback?.invoke(OAuthResult("", OAuthErrorType.USER_CANCELED))
        authCallback = null
    }
    
    /**
     * Set the language for the SDK
     * @param language The language to set
     */
    fun setLanguage(language: String) {
        LanguageManager.setLanguage(language)
    }
    
    /**
     * Get the current language
     * @return Current language
     */
    fun getCurrentLanguage(): String = LanguageManager.getCurrentLanguage()
    
    /**
     * Start Custom Tabs authentication
     */
    private fun startCustomTabsAuthentication(context: Context, authUrl: Uri, config: OAuthConfig) {
        val intent = Intent(context, OAuthActivity::class.java).apply {
            putExtra("auth_url", authUrl.toString())
            putExtra("redirect_uri", config.redirectUri)
            putExtra("auth_mode", BrowserMode.SYSTEM_BROWSER.name)
            // Only add NEW_TASK flag if context is not an Activity
            // This ensures proper back navigation when using Activity context
            if (context !is Activity) {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        }
        
        context.startActivity(intent)
    }
    
    /**
     * Start WebView authentication
     */
    private fun startWebViewAuthentication(context: Context, authUrl: Uri, config: OAuthConfig) {
        val intent = Intent(context, OAuthActivity::class.java).apply {
            putExtra("auth_url", authUrl.toString())
            putExtra("redirect_uri", config.redirectUri)
            putExtra("auth_mode", BrowserMode.WEBVIEW.name)
            // Only add NEW_TASK flag if context is not an Activity
            // This ensures proper back navigation when using Activity context
            if (context !is Activity) {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        }
        
        context.startActivity(intent)
    }
    
    /**
     * Build authorization URL with parameters
     */
    private fun buildAuthorizationUrl(config: OAuthConfig): Uri {
        val state = java.util.UUID.randomUUID().toString()
        
        return Uri.parse(config.authorizationUrl).buildUpon()
            .appendQueryParameter("client_id", config.clientId)
            .appendQueryParameter("redirect_uri", config.redirectUri)
            .appendQueryParameter("response_type", "code")
            .appendQueryParameter("state", state)
            .apply {
                config.scope?.let { appendQueryParameter("scope", it) }
                config.userId?.let { appendQueryParameter("user_id", it) }
                config.language?.let { appendQueryParameter("lang", it) }
                appendQueryParameter("theme", config.themeMode)
            }
            .build()
    }
}
