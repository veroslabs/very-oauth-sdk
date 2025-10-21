package com.veryoauthsdk

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.webkit.WebView
import android.webkit.WebViewClient
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebChromeClient
import android.webkit.PermissionRequest
import androidx.appcompat.app.AppCompatActivity
import androidx.browser.customtabs.CustomTabsIntent
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

/**
 * OAuth authentication activity supporting both Custom Tabs and WebView
 */
class OAuthActivity : AppCompatActivity() {
    
    companion object {
        private const val CAMERA_PERMISSION_REQUEST_CODE = 1001
    }
    
    private lateinit var veryOauthSDK: VeryOauthSDK
    private var redirectUri: String? = null
    private var authMode: AuthenticationMode = AuthenticationMode.SYSTEM_BROWSER
    private var webView: WebView? = null
    private var pendingAuthUrl: String? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        veryOauthSDK = VeryOauthSDK.getInstance()
        redirectUri = intent.getStringExtra("redirect_uri")
        val authUrl = intent.getStringExtra("auth_url")
        val authModeString = intent.getStringExtra("auth_mode")
        
        // Parse authentication mode
        authMode = try {
            AuthenticationMode.valueOf(authModeString ?: AuthenticationMode.SYSTEM_BROWSER.name)
        } catch (e: IllegalArgumentException) {
            AuthenticationMode.SYSTEM_BROWSER
        }
        
        if (authUrl != null) {
            when (authMode) {
                AuthenticationMode.SYSTEM_BROWSER -> startCustomTab(authUrl)
                AuthenticationMode.WEBVIEW -> {
                    pendingAuthUrl = authUrl
                    requestCameraPermissionIfNeeded()
                }
            }
        } else {
            finishWithError(OAuthErrorType.SYSTEM_ERROR)
        }
    }
    
    /**
     * Request camera permission if needed for WebView
     */
    private fun requestCameraPermissionIfNeeded() {
        when (ContextCompat.checkSelfPermission(this, android.Manifest.permission.CAMERA)) {
            PackageManager.PERMISSION_GRANTED -> {
                // Permission already granted
                startWebView(pendingAuthUrl ?: return)
            }
            PackageManager.PERMISSION_DENIED -> {
                // Permission denied, check if we should show rationale
                if (ActivityCompat.shouldShowRequestPermissionRationale(this, android.Manifest.permission.CAMERA)) {
                    // Show rationale and request again
                    showCameraPermissionRationale()
                } else {
                    // Permission permanently denied, proceed without camera
                    showCameraPermissionDeniedMessage()
                    startWebView(pendingAuthUrl ?: return)
                }
            }
            else -> {
                // First time requesting permission
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(android.Manifest.permission.CAMERA),
                    CAMERA_PERMISSION_REQUEST_CODE
                )
            }
        }
    }
    
    /**
     * Handle permission request result
     */
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        when (requestCode) {
            CAMERA_PERMISSION_REQUEST_CODE -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    startWebView(pendingAuthUrl ?: return)
                } else {
                    // Permission denied, show alert and proceed anyway
                    showCameraPermissionDeniedMessage()
                    startWebView(pendingAuthUrl ?: return)
                }
            }
        }
    }
    
    /**
     * Show camera permission rationale
     */
    private fun showCameraPermissionRationale() {
        androidx.appcompat.app.AlertDialog.Builder(this)
            .setTitle(LanguageManager.getCameraPermissionTitle())
            .setMessage(LanguageManager.getCameraPermissionMessage())
            .setPositiveButton(LanguageManager.getGrantPermissionButton()) { _, _ ->
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(android.Manifest.permission.CAMERA),
                    CAMERA_PERMISSION_REQUEST_CODE
                )
            }
            .setNegativeButton(LanguageManager.getContinueWithoutButton()) { _, _ ->
                pendingAuthUrl?.let { startWebView(it) }
            }
            .show()
    }
    
    /**
     * Show camera permission denied message
     */
    private fun showCameraPermissionDeniedMessage() {
        androidx.appcompat.app.AlertDialog.Builder(this)
            .setTitle(LanguageManager.getCameraPermissionDeniedTitle())
            .setMessage(LanguageManager.getCameraPermissionDeniedMessage())
            .setPositiveButton(LanguageManager.getOkButton()) { _, _ ->
                // Continue with authentication
            }
            .show()
    }
    
    /**
     * Start Custom Tab for OAuth authentication
     */
    private fun startCustomTab(url: String) {
        val customTabsIntent = CustomTabsIntent.Builder()
            .setShowTitle(true)
            .setToolbarColor(ContextCompat.getColor(this, android.R.color.white))
            .build()
        
        customTabsIntent.launchUrl(this, Uri.parse(url))
    }
    
    /**
     * Start WebView for OAuth authentication
     */
    private fun startWebView(url: String) {
        webView = WebView(this).apply {
            // Basic settings
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.mediaPlaybackRequiresUserGesture = false
            
            // Security settings - remove deprecated and unsafe options
            settings.allowFileAccess = false
            settings.allowContentAccess = false
            settings.allowFileAccessFromFileURLs = false
            settings.allowUniversalAccessFromFileURLs = false
            
            // Mixed content policy - more secure
            settings.mixedContentMode = android.webkit.WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE
            
            // Additional security settings
            settings.cacheMode = android.webkit.WebSettings.LOAD_NO_CACHE
            settings.databaseEnabled = false
            settings.setGeolocationEnabled(false)
            
            // Handle camera permission requests from WebView
            webChromeClient = object : WebChromeClient() {
                override fun onPermissionRequest(request: PermissionRequest?) {
                    request?.let { permissionRequest ->
                        val resources = permissionRequest.resources
                        if (resources.contains(PermissionRequest.RESOURCE_VIDEO_CAPTURE) || 
                            resources.contains(PermissionRequest.RESOURCE_AUDIO_CAPTURE)) {
                            // Grant camera and microphone permissions
                            permissionRequest.grant(permissionRequest.resources)
                        } else {
                            permissionRequest.deny()
                        }
                    }
                }
            }
            
            webViewClient = object : WebViewClient() {
                override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                    val url = request?.url
                    if (url != null && redirectUri != null) {
                        // Check if URL starts with redirectUri
                        if (url.toString().startsWith(redirectUri!!)) {
                            handleCallback(url)
                            return true
                        }
                    }
                    return false
                }
            }
        }
        
        setContentView(webView)
        webView?.loadUrl(url)
    }
    
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        if (authMode == AuthenticationMode.SYSTEM_BROWSER) {
            handleCallback(intent)
        }
    }
    
    override fun onResume() {
        super.onResume()
        if (authMode == AuthenticationMode.SYSTEM_BROWSER) {
            handleCallback(intent)
        }
    }
    
    /**
     * Handle OAuth callback from Custom Tabs
     */
    private fun handleCallback(intent: Intent?) {
        val data = intent?.data
        if (data != null && redirectUri != null) {
            handleCallback(data)
        }
    }
    
    /**
     * Handle OAuth callback from WebView
     */
    private fun handleCallback(url: Uri) {
        val code = url.getQueryParameter("code")
        val error = url.getQueryParameter("error")
        val state = url.getQueryParameter("state")
        
        when {
            error != null -> {
                finishWithError(OAuthErrorType.VERIFICATION_FAILED)
            }
            code != null -> {
                finishWithSuccess(code, state)
            }
            else -> {
                finishWithError(OAuthErrorType.VERIFICATION_FAILED)
            }
        }
    }
    
    /**
     * Finish with success result
     */
    private fun finishWithSuccess(code: String, state: String?) {
        veryOauthSDK.handleOAuthResult(OAuthResult(code, OAuthErrorType.SUCCESS))
        finish()
    }
    
    /**
     * Finish with error result
     */
    private fun finishWithError(error: OAuthErrorType) {
        veryOauthSDK.handleOAuthResult(OAuthResult("", error))
        finish()
    }
    
    override fun onBackPressed() {
        veryOauthSDK.handleOAuthResult(OAuthResult("", OAuthErrorType.USER_CANCELED))
        super.onBackPressed()
    }
}
