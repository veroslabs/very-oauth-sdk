package com.veryoauthsdk

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.webkit.WebView
import android.webkit.WebViewClient
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebChromeClient
import android.webkit.PermissionRequest
import android.webkit.WebResourceError
import androidx.appcompat.app.AppCompatActivity
import androidx.browser.customtabs.CustomTabsIntent
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

/**
 * OAuth authentication activity supporting both Custom Tabs and WebView
 */
class OAuthActivity : AppCompatActivity() {
    
    
    private lateinit var veryOauthSDK: VeryOauthSDK
    private var redirectUri: String? = null
    private var authMode: BrowserMode = BrowserMode.SYSTEM_BROWSER
    private var webView: WebView? = null
    private var pendingAuthUrl: String? = null
    private var timeoutHandler: Handler? = null
    private var timeoutRunnable: Runnable? = null
    private var isPageLoaded = false
    private var isErrorHandled = false
    
    companion object {
        private const val CAMERA_PERMISSION_REQUEST_CODE = 1001
        private const val WEBVIEW_TIMEOUT_MS = 30000L // 30 seconds timeout
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        veryOauthSDK = VeryOauthSDK.getInstance()
        redirectUri = intent.getStringExtra("redirect_uri")
        val authUrl = intent.getStringExtra("auth_url")
        val authModeString = intent.getStringExtra("auth_mode")
        
        // Parse authentication mode
        authMode = try {
            BrowserMode.valueOf(authModeString ?: BrowserMode.SYSTEM_BROWSER.name)
        } catch (e: IllegalArgumentException) {
            BrowserMode.SYSTEM_BROWSER
        }
        
        if (authUrl != null) {
            when (authMode) {
                BrowserMode.SYSTEM_BROWSER -> startCustomTab(authUrl)
                BrowserMode.WEBVIEW -> {
                    pendingAuthUrl = authUrl
                    requestCameraPermissionIfNeeded()
                }
            }
        } else {
            finishWithError(OAuthErrorType.VERIFICATION_FAILED)
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
                    // User denied before, show rationale and request again
                    showCameraPermissionRationale()
                } else {
                    // First time requesting or permanently denied
                    // Try to request permission first
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(android.Manifest.permission.CAMERA),
                        CAMERA_PERMISSION_REQUEST_CODE
                    )
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
                    // Permission denied - show message and continue anyway
                    // Camera permission is optional for OAuth WebView, so we proceed without it
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
            // Set background color to #1C2125
            setBackgroundColor(0xFF1C2125.toInt())
            
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
            settings.cacheMode = android.webkit.WebSettings.LOAD_DEFAULT
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
                            cancelTimeout()
                            handleCallback(url)
                            return true
                        }
                    }
                    return false
                }
                
                override fun onPageStarted(view: WebView?, url: String?, favicon: android.graphics.Bitmap?) {
                    super.onPageStarted(view, url, favicon)
                    isPageLoaded = false
                    isErrorHandled = false
                    startTimeout()
                }
                
                override fun onPageFinished(view: WebView?, url: String?) {
                    super.onPageFinished(view, url)
                    isPageLoaded = true
                    cancelTimeout()
                }
                
                override fun onReceivedError(
                    view: WebView?,
                    request: WebResourceRequest?,
                    error: WebResourceError?
                ) {
                    super.onReceivedError(view, request, error)
                    
                    // Only handle errors for main frame
                    if (request?.isForMainFrame == true && !isErrorHandled) {
                        isErrorHandled = true
                        cancelTimeout()
                        
                        // Handle network errors based on WebView error callback
                        // This includes DNS failures, connection timeouts, network unavailable, etc.
                        handleNetworkError(OAuthErrorType.NETWORK_ERROR)
                    }
                }
                
                override fun onReceivedHttpError(
                    view: WebView?,
                    request: WebResourceRequest?,
                    errorResponse: WebResourceResponse?
                ) {
                    super.onReceivedHttpError(view, request, errorResponse)
                    
                    // Only handle errors for main frame
                    if (request?.isForMainFrame == true && !isErrorHandled) {
                        isErrorHandled = true
                        cancelTimeout()
                        
                        val statusCode = errorResponse?.statusCode ?: 0
                        // Handle HTTP errors (4xx, 5xx)
                        if (statusCode >= 400) {
                            handleNetworkError(OAuthErrorType.NETWORK_ERROR)
                        }
                    }
                }
            }
        }
        
        // Set Activity background color to match WebView
        // window.decorView.setBackgroundColor(0xFF1C2125.toInt())
        
        setContentView(webView)
        webView?.loadUrl(url)
    }
    
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        if (authMode == BrowserMode.SYSTEM_BROWSER) {
            handleCallback(intent)
        }
    }
    
    override fun onResume() {
        super.onResume()
        if (authMode == BrowserMode.SYSTEM_BROWSER) {
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
                // Check if error is access_denied (user canceled)
                if (error == "access_denied") {
                    finishWithError(OAuthErrorType.USER_CANCELED)
                } else {
                    finishWithError(OAuthErrorType.VERIFICATION_FAILED)
                }
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
    
    /**
     * Start timeout handler
     */
    private fun startTimeout() {
        cancelTimeout()
        timeoutHandler = Handler(Looper.getMainLooper())
        timeoutRunnable = Runnable {
            if (!isPageLoaded && !isErrorHandled) {
                isErrorHandled = true
                handleNetworkError(OAuthErrorType.TIMEOUT)
            }
        }
        timeoutHandler?.postDelayed(timeoutRunnable!!, WEBVIEW_TIMEOUT_MS)
    }
    
    /**
     * Cancel timeout handler
     */
    private fun cancelTimeout() {
        timeoutRunnable?.let { timeoutHandler?.removeCallbacks(it) }
        timeoutRunnable = null
    }
    
    /**
     * Handle network error
     */
    private fun handleNetworkError(errorType: OAuthErrorType) {
        if (!isErrorHandled) {
            isErrorHandled = true
            cancelTimeout()
        }
        finishWithError(errorType)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        cancelTimeout()
        cleanupWebView()
    }
    
    /**
     * Clean up WebView resources
     */
    private fun cleanupWebView() {
        webView?.let {
            it.stopLoading()
            it.clearHistory()
            it.clearCache(true)
            it.loadUrl("about:blank")
            it.onPause()
            it.removeAllViews()
            it.destroy()
            webView = null
        }
    }
    
    override fun onBackPressed() {
        cancelTimeout()
        veryOauthSDK.handleOAuthResult(OAuthResult("", OAuthErrorType.USER_CANCELED))
        finish()
    }
}
