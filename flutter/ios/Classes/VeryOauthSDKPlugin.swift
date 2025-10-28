import Flutter
import UIKit
import VeryOauthSDK

public class VeryOauthSDKPlugin: NSObject, FlutterPlugin {
    private var currentViewController: UIViewController?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "very_oauth_sdk", binaryMessenger: registrar.messenger())
        let instance = VeryOauthSDKPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "authenticate":
            authenticate(call: call, result: result)
        case "cancelAuthentication":
            cancelAuthentication(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func authenticate(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let clientId = args["clientId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "clientId is required", details: nil))
            return
        }
        
        guard let redirectUri = args["redirectUri"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "redirectUri is required", details: nil))
            return
        }
        
        let userId = args["userId"] as? String
        let authorizationUrl = args["authorizationUrl"] as? String
        let scope = args["scope"] as? String
        let browserModeIndex = args["browserMode"] as? Int ?? 1 // Default to webview
        let language = args["language"] as? String
        
        let browserMode: BrowserMode = browserModeIndex == 0 ? .systemBrowser : .webview
        
        let config = OAuthConfig(
            clientId: clientId,
            redirectUri: redirectUri,
            authorizationUrl: authorizationUrl,
            scope: scope,
            browserMode: browserMode,
            userId: userId,
            language: language
        )
        
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No root view controller available", details: nil))
            return
        }
        
        currentViewController = rootViewController
        
        VeryOauthSDK.shared.authenticate(
            config: config,
            presentingViewController: rootViewController
        ) { [weak self] oauthResult in
            DispatchQueue.main.async {
                let resultMap: [String: Any] = [
                    "code": oauthResult.code,
                    "error": oauthResult.error.rawValue
                ]
                result(resultMap)
                self?.currentViewController = nil
            }
        }
    }
    
    private func cancelAuthentication(result: @escaping FlutterResult) {
        VeryOauthSDK.shared.cancelAuthentication()
        result(nil)
    }
}
