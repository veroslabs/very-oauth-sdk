/// OAuth error types
enum OAuthErrorType {
  /// Authentication successful
  success,

  /// User canceled the authentication process
  userCanceled,

  /// Palm scan did not match the registered user
  verificationFailed,

  /// Palm registration was identified as a potential fraud attempt
  registrationFailed,

  /// The authentication request timed out
  timeout,

  /// A network connectivity issue occurred
  networkError,
}
