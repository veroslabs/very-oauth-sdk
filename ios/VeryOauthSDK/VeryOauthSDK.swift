import Foundation
import AuthenticationServices
import UIKit
@preconcurrency import WebKit
import AVFoundation

// MARK: - Authentication Mode
@objc public enum AuthenticationMode: Int, CaseIterable {
    case systemBrowser = 0  // Use system browser (ASWebAuthenticationSession) - default
    case webview = 1        // Use in-app browser (WKWebView)
}

// MARK: - OAuth Configuration
@objcMembers
@objc public class OAuthConfig: NSObject {
    @objc public let clientId: String
    @objc public let redirectUri: String
    @objc public let authorizationUrl: String
    @objc public let scope: String?
    @objc public let authenticationMode: AuthenticationMode
    @objc public let userId: String?
    @objc public let language: String?
    
    @objc public init(clientId: String, redirectUri: String, authorizationUrl: String? = "https://connect.very.org/oauth/authorize", scope: String? = "openid", authenticationMode: AuthenticationMode = .systemBrowser, userId: String? = nil, language: String? = nil) {
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.authorizationUrl = authorizationUrl ?? "https://connect.very.org/oauth/authorize"
        self.scope = scope
        self.authenticationMode = authenticationMode
        self.userId = userId
        self.language = language
    }
}

// MARK: - OAuth Result
@objcMembers
@objc public class OAuthResult: NSObject {
    @objc public class Success: OAuthResult {
        @objc public let token: String
        @objc public let state: String?
        
        @objc public init(token: String, state: String?) {
            self.token = token
            self.state = state
        }
    }
    
    @objc public class Failure: OAuthResult {
        @objc public let error: Error
        
        @objc public init(error: Error) {
            self.error = error
        }
    }
    
    @objc public class Cancelled: OAuthResult {
        @objc public override init() {
            super.init()
        }
    }
}

// MARK: - OAuth Error
public enum OAuthError: Error, LocalizedError {
    case invalidRedirectUri
    case authenticationFailed
    case userCancelled
    case networkError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidRedirectUri:
            return "Invalid redirect URI"
        case .authenticationFailed:
            return "Authentication failed"
        case .userCancelled:
            return "User cancelled authentication"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - VeryOauthSDK Main Class
@available(iOS 12.0, *)
@objcMembers
public class VeryOauthSDK: NSObject {
    
    // MARK: - Properties
    private var webAuthSession: ASWebAuthenticationSession?
    private var webView: WKWebView?
    private var webViewController: UIViewController?
    private var currentConfig: OAuthConfig?
    private var completionHandler: ((OAuthResult) -> Void)?
    
    // Thread-safe properties
    private let queue = DispatchQueue(label: "com.verysdk.queue", attributes: .concurrent)
    
    // MARK: - Public Methods
    
    /// Initialize the SDK
    public override init() {
        super.init()
    }
    
    /// Shared instance for easy access
    @objc public static let shared = VeryOauthSDK()
    
    /// Start OAuth authentication flow
    /// - Parameters:
    ///   - config: OAuth configuration
    ///   - presentingViewController: The view controller to present the authentication from
    ///   - callback: Completion handler with OAuth result
    @objc public func authenticate(
        config: OAuthConfig,
        presentingViewController: UIViewController,
        callback: @escaping (OAuthResult) -> Void
    ) {
        // Thread-safe property updates
        queue.async(flags: .barrier) { [weak self] in
            self?.completionHandler = callback
            self?.currentConfig = config
        }
        
        // Build authorization URL with validation
        guard let authURL = buildAuthorizationURL(with: config) else {
            DispatchQueue.main.async {
                callback(OAuthResult.Failure(error: OAuthError.invalidRedirectUri))
            }
            return
        }
        
        // Validate configuration
        guard validateConfig(config) else {
            DispatchQueue.main.async {
                callback(OAuthResult.Failure(error: OAuthError.invalidRedirectUri))
            }
            return
        }
        
        // Choose authentication mode
        switch config.authenticationMode {
        case .systemBrowser:
            if #available(iOS 13.0, *) {
                startWebAuthenticationSession(with: authURL, config: config)
            } else {
                // Fallback to WebView for iOS 12
                startWebViewAuthentication(with: authURL, config: config, presentingViewController: presentingViewController)
            }
        case .webview:
            startWebViewAuthentication(with: authURL, config: config, presentingViewController: presentingViewController)
        }
    }
    
    /// Cancel current authentication session
    public func cancelAuthentication() {
        webAuthSession?.cancel()
        webAuthSession = nil
        
        // Also cancel WebView authentication if active
        DispatchQueue.main.async { [weak self] in
            self?.webViewController?.dismiss(animated: true) {
                self?.cleanupWebView()
            }
        }
    }
    
    /// Clean up WebView resources
    private func cleanupWebView() {
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView?.stopLoading()
        webView = nil
        webViewController = nil
        
        // Clear completion handler to prevent memory leaks
        queue.async(flags: .barrier) { [weak self] in
            self?.completionHandler = nil
        }
    }
    
    // MARK: - Private Methods
    
    /// Validate OAuth configuration
    private func validateConfig(_ config: OAuthConfig) -> Bool {
        // Check required fields
        guard !config.clientId.isEmpty,
              !config.redirectUri.isEmpty,
              !config.authorizationUrl.isEmpty else {
            return false
        }
        
        // Validate URL format
        guard URL(string: config.authorizationUrl) != nil,
              URL(string: config.redirectUri) != nil else {
            return false
        }
        
        return true
    }
    
    /// Start Web Authentication Session
    @available(iOS 13.0, *)
    private func startWebAuthenticationSession(with authURL: URL, config: OAuthConfig) {
        // Create web authentication session
        webAuthSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: extractScheme(from: config.redirectUri)
        ) { [weak self] callbackURL, error in
            DispatchQueue.main.async {
                self?.handleAuthenticationResult(callbackURL: callbackURL, error: error)
            }
        }
        
        // Configure presentation context
        webAuthSession?.presentationContextProvider = self
        webAuthSession?.prefersEphemeralWebBrowserSession = false
        
        // Start authentication
        webAuthSession?.start()
    }
    
    /// Start WebView Authentication (OPTIMIZED - Smart Camera Permission Handling)
    private func startWebViewAuthentication(with authURL: URL, config: OAuthConfig, presentingViewController: UIViewController) {
        // OPTIMIZED: Check camera permission status but don't block WebView
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraStatus {
        case .authorized:
            // Camera already authorized, proceed directly
            presentWebView(with: authURL, presentingViewController: presentingViewController)
        case .notDetermined:
            // First time, request permission in background (non-blocking)
            requestCameraPermissionInBackground { [weak self] granted in
                // Don't block WebView for camera permission
                DispatchQueue.main.async {
                    self?.presentWebView(with: authURL, presentingViewController: presentingViewController)
                }
            }
        case .denied, .restricted:
            // Permission denied, proceed with WebView anyway (camera is optional)
            presentWebView(with: authURL, presentingViewController: presentingViewController)
        @unknown default:
            // Unknown status, proceed anyway
            presentWebView(with: authURL, presentingViewController: presentingViewController)
        }
    }
    
    /// Request camera permission in background (non-blocking)
    private func requestCameraPermissionInBackground(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            // Log permission result for debugging
            print("📷 Camera permission \(granted ? 'granted' : 'denied')")
            completion(granted)
        }
    }
    
    /// Show camera permission alert
    private func showCameraPermissionAlert(presentingViewController: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Camera Permission",
            message: "Camera access is optional for OAuth authentication. You can still proceed without it, but some features like QR code scanning may not work.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            completion()
        })
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
            completion()
        })
        
        presentingViewController.present(alert, animated: true)
    }
    
    private let sharedDataStore = WKWebsiteDataStore.default()
    
    // MARK: - Data Store Management
    
    /// Clear all website data (cookies, cache, local storage, etc.)
    @objc public func clearAllWebsiteData(completion: @escaping (Bool) -> Void) {
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)
        
        sharedDataStore.removeData(ofTypes: dataTypes, modifiedSince: date) {
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    /// Clear cookies for specific domains
    @objc public func clearCookiesForDomains(_ domains: [String], completion: @escaping (Bool) -> Void) {
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)
        
        sharedDataStore.removeData(ofTypes: dataTypes, modifiedSince: date) {
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    /// Clear cache only
    @objc public func clearCache(completion: @escaping (Bool) -> Void) {
        let cacheTypes: Set<String> = [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]
        let date = Date(timeIntervalSince1970: 0)
        
        sharedDataStore.removeData(ofTypes: cacheTypes, modifiedSince: date) {
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    /// Get current cookies for a specific domain
    @objc public func getCookiesForDomain(_ domain: String, completion: @escaping ([HTTPCookie]) -> Void) {
        sharedDataStore.httpCookieStore.getAllCookies { cookies in
            let filteredCookies = cookies.filter { cookie in
                guard let cookieDomain = cookie.domain else { return false }
                return cookieDomain.contains(domain) || domain.contains(cookieDomain)
            }
            DispatchQueue.main.async {
                completion(filteredCookies)
            }
        }
    }
    
    /// Set cookies for authentication
    @objc public func setCookies(_ cookies: [HTTPCookie], completion: @escaping (Bool) -> Void) {
        let cookieStore = sharedDataStore.httpCookieStore
        
        let group = DispatchGroup()
        var success = true
        
        for cookie in cookies {
            group.enter()
            cookieStore.setCookie(cookie) { error in
                if error != nil {
                    success = false
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(success)
        }
    }
    
    /// Clear authentication data (cookies and local storage)
    @objc public func clearAuthenticationData(completion: @escaping (Bool) -> Void) {
        let authDataTypes: Set<String> = [
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeLocalStorage,
            WKWebsiteDataTypeSessionStorage,
            WKWebsiteDataTypeWebSQLDatabases,
            WKWebsiteDataTypeIndexedDBDatabases
        ]
        let date = Date(timeIntervalSince1970: 0)
        
        sharedDataStore.removeData(ofTypes: authDataTypes, modifiedSince: date) {
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    /// Clear data for specific OAuth domains (recommended for security)
    @objc public func clearOAuthData(completion: @escaping (Bool) -> Void) {
        let oauthDomains = ["connect.very.org", "very.org", "oauth.very.org"]
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)
        
        // Clear data for OAuth-related domains
        sharedDataStore.removeData(ofTypes: dataTypes, modifiedSince: date) {
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    /// Auto-cleanup after authentication (call this after successful auth)
    @objc public func performPostAuthenticationCleanup(completion: @escaping (Bool) -> Void) {
        // Clear sensitive authentication data but keep user preferences
        let sensitiveDataTypes: Set<String> = [
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeSessionStorage,
            WKWebsiteDataTypeWebSQLDatabases,
            WKWebsiteDataTypeIndexedDBDatabases
        ]
        let date = Date(timeIntervalSince1970: 0)
        
        sharedDataStore.removeData(ofTypes: sensitiveDataTypes, modifiedSince: date) {
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    /// Get current data store statistics
    @objc public func getDataStoreStatistics(completion: @escaping ([String: Any]) -> Void) {
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)
        
        sharedDataStore.fetchDataRecords(ofTypes: dataTypes) { records in
            var statistics: [String: Any] = [:]
            statistics["totalRecords"] = records.count
            statistics["domains"] = records.map { $0.displayName }
            statistics["dataTypes"] = Array(dataTypes)
            
            // Calculate total size
            let totalSize = records.reduce(0) { $0 + $1.dataTypes.count }
            statistics["totalSize"] = totalSize
            
            DispatchQueue.main.async {
                completion(statistics)
            }
        }
    }
    
    /// Check if data store has any OAuth-related data
    @objc public func hasOAuthData(completion: @escaping (Bool) -> Void) {
        let oauthDomains = ["connect.very.org", "very.org", "oauth.very.org"]
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        
        sharedDataStore.fetchDataRecords(ofTypes: dataTypes) { records in
            let hasOAuthData = records.contains { record in
                oauthDomains.contains { domain in
                    record.displayName.contains(domain)
                }
            }
            
            DispatchQueue.main.async {
                completion(hasOAuthData)
            }
        }
    }

    private func presentWebView(with authURL: URL, presentingViewController: UIViewController) {
        let configuration = WKWebViewConfiguration()
        
        // Use shared data store for cookie and session persistence
        configuration.websiteDataStore = sharedDataStore
        
        // Configure media playback
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Configure user content controller for better security
        let userContentController = WKUserContentController()
        configuration.userContentController = userContentController
        
        // Configure preferences
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        // Create WebView with configuration
        let webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView = webView
        webView.navigationDelegate = self
        
        // Configure WebView appearance
        webView.backgroundColor = UIColor.systemBackground
        webView.isOpaque = false
        webView.scrollView.bounces = true
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.showsHorizontalScrollIndicator = false

        let webViewController = UIViewController()
        webViewController.view = webView
        self.webViewController = webViewController

        let navigationController = UINavigationController(rootViewController: webViewController)
        webViewController.title = "Authentication"
        
        // Add cancel button
        webViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelWebViewAuthentication)
        )
        
        // Add refresh button for debugging
        webViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshWebView)
        )

        presentingViewController.present(navigationController, animated: true) {
            webView.load(URLRequest(url: authURL))
        }
    }
    
    /// Refresh WebView content
    @objc private func refreshWebView() {
        webView?.reload()
    }
    
    /// Cancel WebView authentication
    @objc private func cancelWebViewAuthentication() {
        DispatchQueue.main.async { [weak self] in
            self?.webViewController?.dismiss(animated: true) {
                self?.webViewController = nil
                self?.webView = nil
                self?.completionHandler?(OAuthResult.Cancelled())
                self?.completionHandler = nil
            }
        }
    }
    
    /// Dismiss WebView if it's currently presented
    private func dismissWebViewIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let webViewController = self.webViewController else { return }
            
            // Only dismiss if it's a WebView authentication (not ASWebAuthenticationSession)
            if self.currentConfig?.authenticationMode == .webview {
                webViewController.dismiss(animated: true) {
                    self.webViewController = nil
                    self.webView = nil
                }
            }
        }
    }
    
    private func buildAuthorizationURL(with config: OAuthConfig) -> URL? {
        var components = URLComponents(string: config.authorizationUrl)
        var queryItems: [URLQueryItem] = []
        
        // Add required parameters
        queryItems.append(URLQueryItem(name: "client_id", value: config.clientId))
        queryItems.append(URLQueryItem(name: "redirect_uri", value: config.redirectUri))
        queryItems.append(URLQueryItem(name: "response_type", value: "code"))
        if let language = config.language {
            queryItems.append(URLQueryItem(name: "lang", value: language))
        }
        if let userId = config.userId {
            queryItems.append(URLQueryItem(name: "user_id", value: userId))
        }
        
        
        // Add optional scope
        if let scope = config.scope {
            queryItems.append(URLQueryItem(name: "scope", value: scope))
        }
        
        // Add state parameter for security
        let state = UUID().uuidString
        queryItems.append(URLQueryItem(name: "state", value: state))
        
        components?.queryItems = queryItems
        
        return components?.url
    }
    
    private func extractScheme(from redirectUri: String) -> String? {
        guard let url = URL(string: redirectUri) else { return nil }
        return url.scheme
    }
    
    private func handleAuthenticationResult(callbackURL: URL?, error: Error?) {
        if let error = error {
            let nsError = error as NSError
            if nsError.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                completionHandler?(OAuthResult.Cancelled())
            } else {
                completionHandler?(OAuthResult.Failure(error: OAuthError.networkError(error)))
            }
            dismissWebViewIfNeeded()
            return
        }
        
        guard let callbackURL = callbackURL else {
            completionHandler?(OAuthResult.Failure(error: OAuthError.authenticationFailed))
            dismissWebViewIfNeeded()
            return
        }
        
        // Parse callback URL to extract authorization code
        if let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            
            // Check for error in callback
            if queryItems.contains(where: { $0.name == "error" }) {
                completionHandler?(OAuthResult.Failure(error: OAuthError.authenticationFailed))
                dismissWebViewIfNeeded()
                return
            }
            
            // Extract authorization code
            if let code = queryItems.first(where: { $0.name == "code" })?.value {
                let state = queryItems.first(where: { $0.name == "state" })?.value
                
                // Perform post-authentication cleanup for security
                performPostAuthenticationCleanup { _ in
                    // Cleanup completed, proceed with success callback
                }
                
                completionHandler?(OAuthResult.Success(token: code, state: state))
            } else {
                completionHandler?(OAuthResult.Failure(error: OAuthError.authenticationFailed))
            }
        } else {
            completionHandler?(OAuthResult.Failure(error: OAuthError.authenticationFailed))
        }
        
        // Clean up
        webAuthSession = nil
        dismissWebViewIfNeeded()
        completionHandler = nil
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
@available(iOS 12.0, *)
extension VeryOauthSDK: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

// MARK: - WKNavigationDelegate
@available(iOS 12.0, *)
extension VeryOauthSDK: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        // Parse callback URL for OAuth parameters
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            
            // Check if URL starts with redirectUri
            if let redirectUri = currentConfig?.redirectUri,
               url.absoluteString.hasPrefix(redirectUri) {
                
                // Check for error in callback
                if queryItems.contains(where: { $0.name == "error" }) {
                    handleAuthenticationResult(callbackURL: nil, error: OAuthError.authenticationFailed)
                } else if queryItems.contains(where: { $0.name == "code" }) {
                    handleAuthenticationResult(callbackURL: url, error: nil)
                } else {
                    handleAuthenticationResult(callbackURL: nil, error: OAuthError.authenticationFailed)
                }
                
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
}
