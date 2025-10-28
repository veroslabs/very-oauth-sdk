Pod::Spec.new do |s|
  s.name             = 'very_oauth_sdk'
  s.version          = '1.0.8'
  s.summary          = 'A Flutter plugin for Very OAuth authentication with palm biometric support.'
  s.description      = <<-DESC
A Flutter plugin for Very OAuth authentication with palm biometric support.
                       DESC
  s.homepage         = 'https://github.com/veroslabs/very-oauth-sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Veros Labs' => 'support@very.org' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'VeryOauthSDK', '~> 1.0.8'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
