Pod::Spec.new do |spec|
  spec.name         = "VeryOauthSDK"
  spec.version = "1.0.10"
  spec.summary      = "VeryOauthSDK - OAuth authentication SDK for iOS"
  spec.description  = <<-DESC
                      VeryOauthSDK provides easy OAuth authentication for iOS apps
                      with support for ASWebAuthenticationSession and WKWebView.
                      DESC

  spec.homepage     = "https://github.com/veroslabs/very-oauth-sdk"
  spec.license      = { :type => "MIT" }
  spec.author       = { "VeryOauthSDK Team" => "support@very.org" }
  spec.source       = { 
    :git => "https://github.com/veroslabs/very-oauth-sdk.git",
    :tag => "#{spec.version}" 
  }

  spec.ios.deployment_target = "12.0"
  spec.swift_versions = ["5.0", "5.5", "5.9"]
  spec.requires_arc = true

  spec.source_files = "ios/VeryOauthSDK/**/*.{swift,h}"

  spec.public_header_files = "ios/VeryOauthSDK/**/*.h"

  spec.module_name = "VeryOauthSDK"
  spec.static_framework = false

  spec.frameworks = "Foundation", "UIKit", "WebKit", "AVFoundation"

  spec.documentation_url = "https://github.com/veroslabs/very-oauth-sdk"
end