//
//  ContentView.swift
//  IOSExample
//
//  Created by yan on 2025/10/10.
//

import SwiftUI
import VeryOauthSDK

// MARK: - Gesture Handler Target
class WindowGestureTarget: NSObject {
    static let shared = WindowGestureTarget()
    private static var gestureRecognizer: UIScreenEdgePanGestureRecognizer?
    
    @objc func handleLeftSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .recognized {
            dismissCurrentNavigationController()
        }
    }
    
    private func dismissCurrentNavigationController() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }),
                  let rootViewController = window.rootViewController else {
                return
            }
            
            // Find the topmost presented view controller
            var topViewController = rootViewController
            while let presented = topViewController.presentedViewController {
                topViewController = presented
            }
            
            // If it's a UINavigationController, dismiss it
            if let navigationController = topViewController as? UINavigationController {
                navigationController.dismiss(animated: true, completion: nil)
            } else if topViewController.presentingViewController != nil {
                // If it's a regular view controller that was presented, dismiss it
                topViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    static func setupGestureRecognizer() {
        // Check if gesture recognizer already exists
        if gestureRecognizer != nil {
            return
        }
        
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                return
            }
            
            // Add left edge swipe gesture to dismiss navigation controller
            let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: WindowGestureTarget.shared, action: #selector(WindowGestureTarget.handleLeftSwipe(_:)))
            edgePanGesture.edges = .left
            window.addGestureRecognizer(edgePanGesture)
            
            // Store reference to avoid duplicates
            gestureRecognizer = edgePanGesture
        }
    }
}

// MARK: - Gesture Handler for Window Level
struct WindowGestureHandler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        // Setup gesture recognizer when view controller is created
        WindowGestureTarget.setupGestureRecognizer()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Ensure gesture recognizer is set up
        WindowGestureTarget.setupGestureRecognizer()
    }
}

struct ContentView: View {
    @State private var authResult: String = "Authentication result will appear here"
    @State private var resultColor: Color = .gray
    @State private var isLoading: Bool = false
    
    // Check device support status
    private let isDeviceSupported = VeryOauthSDK.isSupport()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Title
                VStack(spacing: 10) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("VeryOauthSDK OAuth Demo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Choose a provider and start OAuth authentication")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Device support status
                    Text(isDeviceSupported ? "✅ This device is supported by SDK" : "❌ This device is not supported by SDK")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isDeviceSupported ? .green : .red)
                        .multilineTextAlignment(.center)
                }
                
                
                // Authentication Button
                Button(action: startAuthentication) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "person.badge.key")
                                .font(.system(size: 16, weight: .medium))
                        }
                        
                        Text(isLoading ? "Authenticating..." : "Start OAuth Authentication")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isLoading ? Color.gray : Color.blue)
                    )
                }
                .disabled(isLoading)
                .padding(.horizontal, 40)
                
                // Result Display
                VStack(alignment: .leading, spacing: 10) {
                    Text("Authentication Result:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(authResult)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(resultColor)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding()
        }
        .background(
            WindowGestureHandler()
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
        )
    }
    
    func startAuthentication() {
        isLoading = true
        authResult = "Starting authentication..."
        resultColor = .blue
        
        
        // Get the root view controller from the window
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            authResult = "❌ Error: Could not find root view controller"
            resultColor = .red
            isLoading = false
            return
        }

//         {
//   "sub": "vu-1ed0a927-a336-45dd-9c73-20092db9ae8d"
// }
            // userId: "vu-1ed0a927-a336-45dd-9c73-20092db9ae8d",
        
        let config = OAuthConfig(
            clientId: "veros_145b3a8f2a8f4dc59394cbbd0dd2a77f",
            redirectUri: "https://veros-web-oauth-demo.vercel.app/callback",
            language: "zh-TW",
            themeMode: "light"
        )
        
        
        VeryOauthSDK.shared.authenticate(config: config, presentingViewController: rootViewController) { result in
            DispatchQueue.main.async {
                isLoading = false
                handleAuthenticationResult(result)
            }
        }
    }
    
    func handleAuthenticationResult(_ result: OAuthResult) {
        if result.isSuccess {
            authResult = "✅ Authentication successful!\n\ncode: \(result.code)"
            resultColor = .green
        } else {
            let errorMessage: String
            switch result.error {
            case .deviceNotSupport:
                errorMessage = "❌ Device not supported"
                resultColor = .red
            case .userCanceled:
                errorMessage = "⚠️ Authentication cancelled by user"
                resultColor = .orange
            case .verificationFailed:
                errorMessage = "❌ Verification failed"
                resultColor = .red
            case .registrationFailed:
                errorMessage = "❌ Registration failed"
                resultColor = .red
            case .timeout:
                errorMessage = "❌ Request timeout"
                resultColor = .red
            case .networkError:
                errorMessage = "❌ Network error"
                resultColor = .red
            case .cameraPermissionDenied:
                errorMessage = "❌ Camera Permission Denied"
                resultColor = .red
            default:
                errorMessage = "❌ Unknown error"
                resultColor = .red
            }
            authResult = errorMessage
        }
    }
}


#Preview {
    ContentView()
}
