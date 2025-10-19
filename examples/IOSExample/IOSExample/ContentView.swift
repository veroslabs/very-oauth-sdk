//
//  ContentView.swift
//  IOSExample
//
//  Created by yan on 2025/10/10.
//

import SwiftUI
import VeryOauthSDK

struct ProviderInfo {
    let name: String
    let title: String
    let description: String
    let icon: String
}

struct ContentView: View {
    @State private var authResult: String = "Authentication result will appear here"
    @State private var resultColor: Color = .gray
    @State private var isLoading: Bool = false
    @State private var providers = [
        ProviderInfo(name: "AuthenticationSession", title: "Web Authentication Session", description: "Uses ASWebAuthenticationSession for secure OAuth", icon: "safari"),
        ProviderInfo(name: "WebView", title: "WebView", description: "Uses WKWebView with camera support", icon: "globe")
    ]
    @State private var selectedProvider = "AuthenticationSession"
    
    private let sdk = VeryOauthSDK()
    
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
                
                // Provider Selection
                VStack(alignment: .leading, spacing: 15) {
                    Text("Select Authentication Method:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ForEach(providers, id: \.name) { provider in
                        ProviderRow(
                            provider: provider,
                            isSelected: selectedProvider == provider.name,
                            onTap: { selectedProvider = provider.name }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
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
        authResult = "Starting authentication with \(selectedProvider)..."
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
                    scope: "openid",
            authenticationMode: selectedProvider == "AuthenticationSession" ? .systemBrowser : .webview,
            userId: "vu-1ed0a927-a336-45dd-9c73-20092db9ae8d"
        )
        
        sdk.authenticate(config: config, presentingViewController: rootViewController) { result in
            DispatchQueue.main.async {
                isLoading = false
                handleAuthenticationResult(result)
            }
        }
    }
    
    func handleAuthenticationResult(_ result: OAuthResult) {
        if let success = result as? OAuthResult.Success {
            authResult = "✅ Authentication successful!\n\nToken: \(success.token)\nState: \(success.state ?? "N/A")"
            resultColor = .green
        } else if let failure = result as? OAuthResult.Failure {
            authResult = "❌ Authentication failed:\n\(failure.error.localizedDescription)"
            resultColor = .red
        } else if result is OAuthResult.Cancelled {
            authResult = "⚠️ Authentication cancelled by user"
            resultColor = .orange
        }
    }
}

// MARK: - Provider Row Component
struct ProviderRow: View {
    let provider: ProviderInfo
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                // Icon
                Image(systemName: provider.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 24, height: 24)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(provider.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(provider.description)
                        .font(.system(size: 13))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
