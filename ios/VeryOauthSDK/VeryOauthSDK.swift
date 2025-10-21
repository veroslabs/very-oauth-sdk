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
@objc public class OAuthConfig: NSObject {
    @objc public let clientId: String
    @objc public let redirectUri: String
    @objc public let userId: String?
    @objc public let authorizationUrl: String?
    @objc public var scope: String?
    @objc public var authenticationMode: AuthenticationMode
    @objc public var language: String?
    
    @objc public init(clientId: String, redirectUri: String, authorizationUrl: String? = "https://connect.very.org/oauth/authorize", scope: String? = "openid", authenticationMode: AuthenticationMode = .webview, userId: String? = nil, language: String? = nil) {
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.authorizationUrl = authorizationUrl
        self.scope = scope
        self.authenticationMode = authenticationMode
        self.userId = userId
        self.language = language
    }
    
    // MARK: - Convenience Initializer for Minimal Configuration
    @objc public convenience init(clientId: String, redirectUri: String, userId: String) {
        self.init(clientId: clientId, redirectUri: redirectUri, authorizationUrl: "https://connect.very.org/oauth/authorize", scope: "openid", authenticationMode: .webview, userId: userId, language: nil)
    }
}

// MARK: - OAuth Error Types
@objc public enum OAuthErrorType: Int, CaseIterable {
    case success = 0
    case userCanceled = 1
    case systemError = 2
    case verificationFailed = 3
    case registrationFailed = 4
    case timeout = 5
    case networkError = 6
}

// MARK: - OAuth Result
@objc public class OAuthResult: NSObject {
    @objc public let code: String
    @objc public let error: OAuthErrorType
    
    @objc public init(code: String, error: OAuthErrorType = .systemError) {
        self.code = code
        self.error = error
    }
    
    @objc public var isSuccess: Bool {
        return error == .success
    }
}


// MARK: - VeryOauthSDK Main Class
@available(iOS 12.0, *)
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
                callback(OAuthResult(code: "", error: .systemError))
            }
            return
        }
        
        // Validate configuration
        guard validateConfig(config) else {
            DispatchQueue.main.async {
                callback(OAuthResult(code: "", error: .systemError))
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
                        self?.handleError(error: .verificationFailed)
                    }
                }
            }
        case .denied, .restricted:
            // Permission denied, show alert and proceed anyway (WebView might not need camera)
            showCameraPermissionAlert(presentingViewController: presentingViewController) { [weak self] in
                self?.presentWebView(with: authURL, presentingViewController: presentingViewController)
            }
        @unknown default:
            // Unknown status, proceed anyway
            presentWebView(with: authURL, presentingViewController: presentingViewController)
        }
    }
    
    /// Request camera permission
    private func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
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
        
        // Create view controller to present WebView
        let webViewController = UIViewController()
        webViewController.view = webView
        self.webViewController = webViewController
        
        // Configure WebView delegates
        webView.navigationDelegate = self
        webView.uiDelegate = self  // Set UI delegate for media permissions
        
        // Present WebView
        let navigationController = UINavigationController(rootViewController: webViewController)
        navigationController.modalPresentationStyle = .pageSheet
        
        // Add cancel button
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelWebViewAuthentication))
        webViewController.navigationItem.leftBarButtonItem = cancelButton
        
        presentingViewController.present(navigationController, animated: true)
        
        // Load authorization URL
        let request = URLRequest(url: authURL)
        webView.load(request)
    }
    
    /// Cancel WebView authentication
    @objc private func cancelWebViewAuthentication() {
        DispatchQueue.main.async { [weak self] in
            self?.webViewController?.dismiss(animated: true) {
                self?.webViewController = nil
                self?.webView = nil
                self?.handleError(error: .userCanceled)
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

    private func handleError(error: OAuthErrorType) {
        completionHandler?(OAuthResult(code: "", error: error))
        dismissWebViewIfNeeded()
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
                completionHandler?(OAuthResult(code: code, error: .success))
            } else {
                handleError(error: .verificationFailed)
            }
        } else {
            handleError(error: .verificationFailed)
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
                
                // Check for error in callback
                if queryItems.contains(where: { $0.name == "error" }) {
                    handleAuthenticationResult(callbackURL: nil, error: .verificationFailed)
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


    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView failed to load: \(error.localizedDescription)")
        handleAuthenticationResult(callbackURL: nil, error: .networkError)
    }
    
   
}
