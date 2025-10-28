import 'browser_mode.dart';

/// OAuth configuration for authentication
class OAuthConfig {
  /// The OAuth client ID assigned to your application
  final String clientId;

  /// The OAuth redirect URI registered for your application
  final String redirectUri;

  /// For enrollment, use an empty string. For verification, use the external_user_id string
  final String? userId;

  /// The authorization URL (defaults to https://connect.very.org/oauth/authorize)
  final String? authorizationUrl;

  /// The OAuth scope (defaults to "openid")
  final String? scope;

  /// Browser mode for authentication (defaults to webview)
  final BrowserMode browserMode;

  /// Language preference for the authentication UI
  final String? language;

  const OAuthConfig({
    required this.clientId,
    required this.redirectUri,
    this.userId,
    this.authorizationUrl,
    this.scope,
    this.browserMode = BrowserMode.webview,
    this.language,
  });

  /// Convenience constructor for minimal configuration
  OAuthConfig.minimal({
    required this.clientId,
    required this.redirectUri,
    required this.userId,
  })  : authorizationUrl = 'https://connect.very.org/oauth/authorize',
        scope = 'openid',
        browserMode = BrowserMode.webview,
        language = null;

  /// Convert to map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'redirectUri': redirectUri,
      'userId': userId,
      'authorizationUrl': authorizationUrl,
      'scope': scope,
      'browserMode': browserMode.index,
      'language': language,
    };
  }

  /// Create from map (for platform channel communication)
  factory OAuthConfig.fromMap(Map<String, dynamic> map) {
    return OAuthConfig(
      clientId: map['clientId'] as String,
      redirectUri: map['redirectUri'] as String,
      userId: map['userId'] as String?,
      authorizationUrl: map['authorizationUrl'] as String?,
      scope: map['scope'] as String?,
      browserMode: BrowserMode.values[map['browserMode'] as int],
      language: map['language'] as String?,
    );
  }
}
