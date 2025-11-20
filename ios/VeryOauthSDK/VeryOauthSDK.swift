import Foundation
import AuthenticationServices
import UIKit
@preconcurrency import WebKit
import AVFoundation

// MARK: - Authentication Mode
@objc public enum BrowserMode: Int, CaseIterable {
    case systemBrowser = 0  // Use system browser (ASWebAuthenticationSession) - default
    case webview = 1        // Use in-app browser (WKWebView)
}

// MARK: - OAuth Configuration
@objc public class OAuthConfig: NSObject {
    @objc public let clientId: String
    @objc public let redirectUri: String
    @objc public let userId: String?
    @objc public let authorizationUrl: String?
    @objc public var scope: String?
    @objc public var browserMode: BrowserMode
    @objc public var language: String?
    @objc public var themeMode: String
    
    @objc public init(clientId: String, redirectUri: String, authorizationUrl: String? = "https://connect.very.org/oauth/authorize", scope: String? = "openid", browserMode: BrowserMode = .webview, userId: String? = nil, language: String? = nil, themeMode: String = "dark") {
        // Validate themeMode
        guard themeMode == "light" || themeMode == "dark" else {
            fatalError("themeMode must be either 'light' or 'dark'")
        }
        
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.authorizationUrl = authorizationUrl
        self.scope = scope
        self.browserMode = browserMode
        self.userId = userId
        self.language = language
        self.themeMode = themeMode
    }
    
    // MARK: - Convenience Initializer for Minimal Configuration
    @objc public convenience init(clientId: String, redirectUri: String, userId: String) {
        self.init(clientId: clientId, redirectUri: redirectUri, authorizationUrl: "https://connect.very.org/oauth/authorize", scope: "openid", browserMode: .webview, userId: userId, language: nil, themeMode: "dark")
    }
}

// MARK: - OAuth Error Types
@objc public enum OAuthErrorType: Int, CaseIterable {
    case success = 0
    case userCanceled = 1
    case verificationFailed = 3
    case registrationFailed = 4
    case timeout = 5
    case networkError = 6
    case cameraPermissionDenied = 7
}

// MARK: - OAuth Result
@objc public class OAuthResult: NSObject {
    @objc public let code: String
    @objc public let error: OAuthErrorType
    
    @objc public init(code: String, error: OAuthErrorType = .verificationFailed) {
        self.code = code
        self.error = error
    }
    
    @objc public var isSuccess: Bool {
        return error == .success
    }
}


// MARK: - Custom WebViewController to detect dismissal
@available(iOS 12.0, *)
private class OAuthWebViewController: UIViewController {
    weak var sdkInstance: VeryOauthSDK?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async { [weak self] in
            guard let sdk = self?.sdkInstance else { return }
            if !sdk.isErrorHandled {
                sdk.handleError(error: .userCanceled)
            }
        }
    }
}

// MARK: - VeryOauthSDK Main Class
@available(iOS 12.0, *)
public class VeryOauthSDK: NSObject {
    
    // MARK: - Properties
    private var webAuthSession: ASWebAuthenticationSession?
    private var webView: WKWebView?
    private var webViewController: UIViewController?
    private var navigationController: UINavigationController?
    private var currentConfig: OAuthConfig?
    private var completionHandler: ((OAuthResult) -> Void)?
    
    // Network error handling properties
    private var timeoutTimer: Timer?
    private var isPageLoaded = false
    internal var isErrorHandled = false // Make internal so OAuthWebViewController can access
    
    // Thread-safe properties
    private let queue = DispatchQueue(label: "com.verysdk.queue", attributes: .concurrent)
    
    // Constants
    private let webViewTimeout: TimeInterval = 30.0 // 30 seconds timeout
    
    // Language mapping for Cancel button
    private static let cancelButtonTexts: [String: String] = [
        "ar-AE": "إلغاء",
        "az-AZ": "Ləğv et",
        "bg-BG": "Отказ",
        "bn-BD": "বাতিল",
        "cs-CZ": "Zrušit",
        "da-DK": "Annuller",
        "de-DE": "Abbrechen",
        "el-GR": "Ακύρωση",
        "en-GB": "Cancel",
        "en-IN": "Cancel",
        "en-TR": "Cancel",
        "en-US": "Cancel",
        "es-ES": "Cancelar",
        "et-EE": "Tühista",
        "fa-IR": "لغو",
        "fi-FI": "Peruuta",
        "fil-PH": "Kanselahin",
        "fr-FR": "Annuler",
        "he-IL": "ביטול",
        "hi-IN": "रद्द करें",
        "hr-HR": "Odustani",
        "hu-HU": "Mégse",
        "id-ID": "Batal",
        "it-IT": "Annulla",
        "ja-JP": "キャンセル",
        "kk-KZ": "Болдырмау",
        "ko-KR": "취소",
        "lo-LA": "ຍົກເລີກ",
        "lt-LT": "Atšaukti",
        "lv-LV": "Atcelt",
        "ms-MY": "Batal",
        "nb-NO": "Avbryt",
        "nl-NL": "Annuleren",
        "pl-PL": "Anuluj",
        "pt-BR": "Cancelar",
        "pt-PT": "Cancelar",
        "ro-RO": "Anulează",
        "ru-RU": "Отмена",
        "si-LK": "අවලංගු කරන්න",
        "sk-SK": "Zrušiť",
        "sl-SI": "Prekliči",
        "sv-SE": "Avbryt",
        "th-TH": "ยกเลิก",
        "tr-CT": "İptal",
        "tr-TR": "İptal",
        "uk-UA": "Скасувати",
        "vi-VN": "Hủy",
        "zh-MY": "取消",
        "zh-TW": "取消"
    ]
    
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
                callback(OAuthResult(code: "", error: .verificationFailed))
            }
            return
        }
        
        // Validate configuration
        guard validateConfig(config) else {
            DispatchQueue.main.async {
                callback(OAuthResult(code: "", error: .verificationFailed))
            }
            return
        }
        
        // Choose authentication mode
        switch config.browserMode {
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
        cancelTimeout()
        webAuthSession?.cancel()
        webAuthSession = nil
        
        // Trigger userCanceled error callback
        // handleError will call dismissWebViewIfNeeded which will clean up
        handleError(error: .userCanceled)
    }
    
    /// Clean up WebView resources
    private func cleanupWebView() {
        cancelTimeout()
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView?.stopLoading()
        webView = nil
        webViewController = nil
        
        // Reset error handling state
        isPageLoaded = false
        isErrorHandled = false
        
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
              let authorizationUrl = config.authorizationUrl, !authorizationUrl.isEmpty else {
            return false
        }
        
        // Validate URL format
        guard URL(string: authorizationUrl) != nil,
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
                if let error = error {
                    let nsError = error as NSError
                    if nsError.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        self?.handleAuthenticationResult(callbackURL: callbackURL, error: .userCanceled)
                    } else {
                        self?.handleAuthenticationResult(callbackURL: callbackURL, error: .networkError)
                    }
                } else {
                    self?.handleAuthenticationResult(callbackURL: callbackURL, error: nil)
                }
            }
        }
        
        // Configure presentation context
        webAuthSession?.presentationContextProvider = self
        webAuthSession?.prefersEphemeralWebBrowserSession = false
        
        // Start authentication
        webAuthSession?.start()
    }
    
    /// Start WebView Authentication
    private func startWebViewAuthentication(with authURL: URL, config: OAuthConfig, presentingViewController: UIViewController) {
        // Check camera permission status first
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraStatus {
        case .authorized:
            // Camera already authorized, proceed directly
            presentWebView(with: authURL, presentingViewController: presentingViewController)
        case .notDetermined:
            // First time, request permission
            requestCameraPermission { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.presentWebView(with: authURL, presentingViewController: presentingViewController)
                    } else {
                        self?.handleError(error: .cameraPermissionDenied)
                    }
                }
            }
        case .denied, .restricted:
            // Permission denied, show alert and require camera permission
            showCameraPermissionAlert(presentingViewController: presentingViewController)
        @unknown default:
            // Unknown status, require camera permission
            showCameraPermissionAlert(presentingViewController: presentingViewController)
        }
    }
    
    /// Request camera permission
    private func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            completion(granted)
        }
    }
    
    /// Show camera permission alert
    private func showCameraPermissionAlert(presentingViewController: UIViewController) {
        let alert = UIAlertController(
            title: "Camera Permission",
            message: "Camera access is required for OAuth authentication. Please grant camera permission to continue.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Close", style: .default) { [weak self] _ in
            self?.handleError(error: .cameraPermissionDenied)
        })
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { [weak self] _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
            // After opening settings, still return camera permission denied error
            self?.handleError(error: .cameraPermissionDenied)
        })
        
        presentingViewController.present(alert, animated: true)
    }
    
    /// Present WebView with camera support
    private func presentWebView(with authURL: URL, presentingViewController: UIViewController) {
        // Create WebView configuration with camera support
        let configuration = WKWebViewConfiguration()
        // Enable camera access for WebView
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Create WebView with configuration
        let webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView = webView
        
        // Set WebView background color
        webView.backgroundColor = UIColor(red: 0x1C/255.0, green: 0x21/255.0, blue: 0x25/255.0, alpha: 1.0)
        webView.isOpaque = false
        
        // Create custom view controller to present WebView with dismissal detection
        let webViewController = OAuthWebViewController()
        webViewController.sdkInstance = self
        webViewController.view = webView
        webViewController.view.backgroundColor = UIColor(red: 0x1C/255.0, green: 0x21/255.0, blue: 0x25/255.0, alpha: 1.0)
        self.webViewController = webViewController
        
        // Configure WebView delegates
        webView.navigationDelegate = self
        webView.uiDelegate = self  // Set UI delegate for media permissions


        
        // Present WebView
        let navigationController = UINavigationController(rootViewController: webViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController = navigationController
        
        // Set presentation controller delegate to detect dismissal
        if let presentationController = navigationController.presentationController {
            presentationController.delegate = self
        }
        
        // Add cancel button with localized text
        let cancelText = getCancelButtonText()
        let cancelButton = UIBarButtonItem(title: cancelText, style: .plain, target: self, action: #selector(cancelWebViewAuthentication))
        webViewController.navigationItem.leftBarButtonItem = cancelButton
        
        presentingViewController.present(navigationController, animated: true)
        
        // Reset error handling state
        isPageLoaded = false
        isErrorHandled = false
        
        // Load authorization URL
        let request = URLRequest(url: authURL)
        webView.load(request)
        
        // Start timeout timer
        startTimeout()
    }
    
    /// Start timeout timer
    private func startTimeout() {
        cancelTimeout()
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: webViewTimeout, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                if let self = self, !self.isPageLoaded && !self.isErrorHandled {
                    self.isErrorHandled = true
                    self.handleError(error: .timeout)
                }
            }
        }
    }
    
    /// Cancel timeout timer
    private func cancelTimeout() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
    
    /// Get localized Cancel button text based on language
    private func getCancelButtonText() -> String {
        guard let language = currentConfig?.language,
              let localizedText = VeryOauthSDK.cancelButtonTexts[language] else {
            return "Cancel" // Default to English
        }
        return localizedText
    }
    
    /// Cancel WebView authentication
    @objc private func cancelWebViewAuthentication() {
        handleError(error: .userCanceled)
    }
    
    /// Dismiss WebView if it's currently presented
    private func dismissWebViewIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let navigationController = self.navigationController else { return }
            
            // Only dismiss if it's a WebView authentication (not ASWebAuthenticationSession)
            if self.currentConfig?.browserMode == .webview {
                navigationController.dismiss(animated: true) {
                    self.cleanupWebView()
                }
            }
        }
    }
    
    private func buildAuthorizationURL(with config: OAuthConfig) -> URL? {
        guard let authorizationUrl = config.authorizationUrl else { return nil }
        var components = URLComponents(string: authorizationUrl)
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
        
        // Add theme parameter
        queryItems.append(URLQueryItem(name: "theme", value: config.themeMode))
        
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

    internal func handleError(error: OAuthErrorType) {
        if !isErrorHandled {
            isErrorHandled = true
            cancelTimeout()
            completionHandler?(OAuthResult(code: "", error: error))
            dismissWebViewIfNeeded()
        }

    }
    
    private func handleAuthenticationResult(callbackURL: URL?, error: OAuthErrorType? = nil) {
        if let error = error {
            handleError(error: error)
            return
        }
        
        guard let callbackURL = callbackURL else {
            handleError(error: .verificationFailed)
            return
        }
        
        
        // Parse callback URL to extract authorization code
        if let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            
            // Check for error in callback
            if queryItems.contains(where: { $0.name == "error" }) {
                handleError(error: .verificationFailed)
                return
            }
            
            // Extract authorization code
            if let code = queryItems.first(where: { $0.name == "code" })?.value {
                let state = queryItems.first(where: { $0.name == "state" })?.value
                // Mark as handled before calling completion handler to prevent dismissal detection from triggering cancel
                isErrorHandled = true
                completionHandler?(OAuthResult(code: code, error: .success))
                // Clean up after successful authentication
                webAuthSession = nil
                dismissWebViewIfNeeded()
                // Note: completionHandler will be cleared in cleanupWebView() after dismiss completes
            } else {
                handleError(error: .verificationFailed)
            }
        } else {
            handleError(error: .verificationFailed)
        }
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
@available(iOS 12.0, *)
extension VeryOauthSDK: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
@available(iOS 13.0, *)
extension VeryOauthSDK: UIAdaptivePresentationControllerDelegate {
    /// Called when the modal is dismissed (e.g., by swipe down gesture or left swipe)
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // Only trigger cancel if error hasn't been handled yet
        // This prevents canceling when authentication succeeds
        if !isErrorHandled {
            handleError(error: .userCanceled)
        }
    }
}

// MARK: - WKUIDelegate
@available(iOS 12.0, *)
extension VeryOauthSDK: WKUIDelegate {
    
    /// Handle media permission requests (camera/microphone) in WebView
    @available(iOS 15.0, *)
    public func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        
        print("📷 WebView requesting media permission for: \(origin.host)")
        
        // Check if we already have camera permission
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraStatus {
        case .authorized:
            // Already authorized, grant permission immediately
            print("📷 Camera already authorized, granting WebView permission")
            decisionHandler(.grant)
            
        case .notDetermined:
            // Request permission and grant to WebView
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        print("📷 Camera permission granted, allowing WebView access")
                        decisionHandler(.grant)
                    } else {
                        print("📷 Camera permission denied, denying WebView access")
                        decisionHandler(.deny)
                    }
                }
            }
            
        case .denied, .restricted:
            // Permission denied, deny WebView access
            print("📷 Camera permission denied, denying WebView access")
            decisionHandler(.deny)
            
        @unknown default:
            print("📷 Unknown camera permission status, denying WebView access")
            decisionHandler(.deny)
        }
    }
    
    /// Handle file upload requests (fallback for older iOS versions)
    public func webView(_ webView: WKWebView, runOpenPanelWith parameters: Any, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        // For file uploads, we can implement custom logic here if needed
        // For now, we'll just deny file uploads to keep it simple
        completionHandler(nil)
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
                    
                    // Cancel timeout when callback is received
                    cancelTimeout()
                    
                    // Check for error in callback
                    if queryItems.contains(where: { $0.name == "error" }) {
                        if queryItems.first(where: { $0.name == "error" })?.value == "access_denied" {
                            handleAuthenticationResult(callbackURL: nil, error: .userCanceled)
                        } else {
                            handleAuthenticationResult(callbackURL: nil, error: .verificationFailed)
                        }
                    } else if queryItems.contains(where: { $0.name == "code" }) {
                        handleAuthenticationResult(callbackURL: url, error: nil)
                    } else {
                        handleAuthenticationResult(callbackURL: nil, error: .verificationFailed)
                    }
                    
                    decisionHandler(.cancel)
                    return
                }
        }
        
        decisionHandler(.allow)
    }


    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Page started loading
        isPageLoaded = false
        isErrorHandled = false
        startTimeout()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Page finished loading
        isPageLoaded = true
        cancelTimeout()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WebView failed provisional navigation: \(error.localizedDescription)")
        handleAuthenticationResult(callbackURL: nil, error: .networkError)
        
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView failed to load: \(error.localizedDescription)")
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            return
        }

        handleAuthenticationResult(callbackURL: nil, error: .networkError)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        // Handle HTTP errors (4xx, 5xx)
        if let httpResponse = navigationResponse.response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            if statusCode >= 400 {
                print("WebView received HTTP error: \(statusCode)")
                handleAuthenticationResult(callbackURL: nil, error: .networkError)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
}
