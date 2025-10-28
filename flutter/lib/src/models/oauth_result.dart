import 'oauth_error_type.dart';

/// OAuth authentication result
class OAuthResult {
  /// The authorization code returned in the callback
  final String code;

  /// The error type, if the authentication process fails
  final OAuthErrorType error;

  /// Indicates whether the authentication was successful
  bool get isSuccess => error == OAuthErrorType.success;

  const OAuthResult({
    required this.code,
    this.error = OAuthErrorType.verificationFailed,
  });

  /// Create success result
  factory OAuthResult.success(String code) {
    return OAuthResult(
      code: code,
      error: OAuthErrorType.success,
    );
  }

  /// Create error result
  factory OAuthResult.error(OAuthErrorType error) {
    return OAuthResult(
      code: '',
      error: error,
    );
  }

  /// Convert to map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'error': error.index,
    };
  }

  /// Create from map (for platform channel communication)
  factory OAuthResult.fromMap(Map<String, dynamic> map) {
    return OAuthResult(
      code: map['code'] as String,
      error: OAuthErrorType.values[map['error'] as int],
    );
  }

  @override
  String toString() {
    return 'OAuthResult(code: $code, error: $error, isSuccess: $isSuccess)';
  }
}
