import 'dart:async';

import 'package:flutter/services.dart';

import 'models/oauth_config.dart';
import 'models/oauth_error_type.dart';
import 'models/oauth_result.dart';

/// Very OAuth SDK for Flutter
class VeryOauthSDK {
  static const MethodChannel _channel = MethodChannel('very_oauth_sdk');

  /// Start OAuth authentication flow
  /// 
  /// [config] - OAuth configuration
  /// 
  /// Returns a [Future<OAuthResult>] with the authentication result
  static Future<OAuthResult> authenticate(OAuthConfig config) async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'authenticate',
        config.toMap(),
      );
      
      if (result == null) {
        return OAuthResult.error(OAuthErrorType.verificationFailed);
      }
      
      return OAuthResult.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      // Handle platform-specific errors
      switch (e.code) {
        case 'USER_CANCELED':
          return OAuthResult.error(OAuthErrorType.userCanceled);
        case 'VERIFICATION_FAILED':
          return OAuthResult.error(OAuthErrorType.verificationFailed);
        case 'REGISTRATION_FAILED':
          return OAuthResult.error(OAuthErrorType.registrationFailed);
        case 'TIMEOUT':
          return OAuthResult.error(OAuthErrorType.timeout);
        case 'NETWORK_ERROR':
          return OAuthResult.error(OAuthErrorType.networkError);
        default:
          return OAuthResult.error(OAuthErrorType.verificationFailed);
      }
    } catch (e) {
      // Handle any other errors
      return OAuthResult.error(OAuthErrorType.verificationFailed);
    }
  }

  /// Cancel current authentication session
  static Future<void> cancelAuthentication() async {
    try {
      await _channel.invokeMethod('cancelAuthentication');
    } catch (e) {
      // Ignore errors when canceling
    }
  }
}
