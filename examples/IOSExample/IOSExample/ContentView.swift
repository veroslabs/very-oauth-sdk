//
//  ContentView.swift
//  IOSExample
//
//  Created by yan on 2025/10/10.
//

import SwiftUI
import VeryOauthSDK


struct ContentView: View {
    @State private var authResult: String = "Authentication result will appear here"
    @State private var resultColor: Color = .gray
    @State private var isLoading: Bool = false
    

    
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
        
        let config = OAuthConfig(
            clientId: "veros_145b3a8f2a8f4dc59394cbbd0dd2a77f",
            redirectUri: "https://veros-web-oauth-demo.vercel.app/callback",
            userId: "vu-1ed0a927-a336-45dd-9c73-20092db9ae8d"
        )
        
        VeryOauthSDK().authenticate(config: config, presentingViewController: rootViewController) { result in
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
            case .userCanceled:
                errorMessage = "⚠️ Authentication cancelled by user"
                resultColor = .orange
            case .systemError:
                errorMessage = "❌ System error occurred"
                resultColor = .red
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
