/// Browser mode for OAuth authentication
enum BrowserMode {
  /// Use system browser (ASWebAuthenticationSession on iOS, Custom Tabs on Android)
  systemBrowser,

  /// Use in-app browser (WKWebView on iOS, WebView on Android)
  webview,
}
