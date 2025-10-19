package com.veryoauthsdk

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.browser.customtabs.CustomTabsIntent
import androidx.core.content.ContextCompat
import kotlinx.coroutines.*

/**
 * Authentication mode enum
 */
enum class AuthenticationMode {
    SYSTEM_BROWSER,    // Use system browser (Custom Tabs) - default
    WEBVIEW            // Use in-app browser (WebView)
}

/**
 * OAuth configuration class
 */
class OAuthConfig @JvmOverloads constructor(
    val clientId: String,
    val redirectUri: String,
    val authorizationUrl: String,
    val scope: String? = null,
    val authenticationMode: AuthenticationMode = AuthenticationMode.SYSTEM_BROWSER,
    val userId: String? = null
)

/**
 * OAuth result sealed class
 */
sealed class OAuthResult {
    data class Success(val token: String, val state: String?) : OAuthResult()
    data class Failure(val error: Throwable) : OAuthResult()
    object Cancelled : OAuthResult()
}

/**
 * OAuth error types
 */
sealed class OAuthError : Exception() {
    object InvalidRedirectUri : OAuthError()
    object AuthenticationFailed : OAuthError()
    object UserCancelled : OAuthError()
    data class NetworkError(val error: Throwable) : OAuthError()
}

/**
 * Main VeryOauthSDK class for OAuth authentication
 */
class VeryOauthSDK private constructor() {
    
    companion object {
        @Volatile
        private var INSTANCE: VeryOauthSDK? = null
        
        @JvmStatic
        fun getInstance(): VeryOauthSDK {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: VeryOauthSDK().also { INSTANCE = it }
            }
        }
    }
    
    private var authCallback: ((OAuthResult) -> Unit)? = null
    private var customTabsIntent: CustomTabsIntent? = null
    private var language: Language = Language.ENGLISH
    
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
        this.authCallback = callback
        
        try {
            val authUrl = buildAuthorizationUrl(config)
            
            when (config.authenticationMode) {
                AuthenticationMode.SYSTEM_BROWSER -> {
                    startCustomTabsAuthentication(context, authUrl, config)
                }
                AuthenticationMode.WEBVIEW -> {
                    startWebViewAuthentication(context, authUrl, config)
                }
            }
        } catch (e: Exception) {
            callback(OAuthResult.Failure(OAuthError.InvalidRedirectUri))
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
        authCallback?.invoke(OAuthResult.Cancelled)
        authCallback = null
    }
    
    /**
     * Set the language for the SDK
     * @param language The language to set
     */
    fun setLanguage(language: Language) {
        this.language = language
        LanguageManager.setLanguage(language)
    }
    
    /**
     * Get the current language
     * @return Current language
     */
    fun getCurrentLanguage(): Language = language
    
    /**
     * Start Custom Tabs authentication
     */
    private fun startCustomTabsAuthentication(context: Context, authUrl: Uri, config: OAuthConfig) {
        val intent = Intent(context, OAuthActivity::class.java).apply {
            putExtra("auth_url", authUrl.toString())
            putExtra("redirect_uri", config.redirectUri)
            putExtra("auth_mode", AuthenticationMode.SYSTEM_BROWSER.name)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
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
            putExtra("auth_mode", AuthenticationMode.WEBVIEW.name)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
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
            }
            .build()
    }
}
