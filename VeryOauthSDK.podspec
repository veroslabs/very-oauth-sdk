Pod::Spec.new do |spec|
  spec.name         = "VeryOauthSDK"
  spec.version      = "1.0.5"
  spec.summary      = "VeryOauthSDK - OAuth authentication SDK for iOS"
  spec.description  = <<-DESC
                      VeryOauthSDK provides easy OAuth authentication for iOS apps
                      with support for ASWebAuthenticationSession and WKWebView.
                      Features include:
                      - Dual authentication modes (ASWebAuthenticationSession / WKWebView)
                      - Camera permission support for WebView
                      - Complete OAuth 2.0 flow
                      - Modern Swift API
                      - iOS 12.0+ support
                      DESC
  
  spec.homepage     = "https://github.com/veroslabs/very-oauth-sdk"
  spec.license      = { :type => "MIT" }
  spec.author       = { "VeryOauthSDK Team" => "tongliang@very.org" }
  spec.source       = { 
    :git => "https://github.com/veroslabs/very-oauth-sdk.git", 
    :tag => "#{spec.version}" 
  }
  
  spec.ios.deployment_target = "12.0"
  spec.swift_version = "5.0"
  
  spec.source_files = "ios/VeryOauthSDK/**/*.swift"
  
  spec.frameworks = "Foundation", "UIKit", "WebKit", "AVFoundation"
  spec.requires_arc = true
  
  spec.documentation_url = "https://github.com/veroslabs/very-oauth-sdk"
  spec.social_media_url = "https://github.com/veroslabs/very-oauth-sdk"
  
end