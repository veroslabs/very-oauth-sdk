import 'package:flutter/material.dart';
import 'package:very_oauth_sdk/very_oauth_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Very OAuth SDK Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MyHomePage(title: 'Very OAuth SDK Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _status = 'Ready to authenticate';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Title Section
            Column(
              children: [
                const Icon(Icons.security, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'VeryOauthSDK OAuth Demo',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose authentication method and start OAuth authentication',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Authentication Button (WebView only)
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _authenticateWithWebView,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.web),
              label: Text(
                _isLoading ? 'Authenticating...' : 'Start OAuth Authentication',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Status Section
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Authentication Result:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _authenticateWithWebView() async {
    setState(() {
      _isLoading = true;
      _status = 'Starting authentication...';
    });

    try {
      // Use minimal configuration similar to iOS example
      final config = OAuthConfig.minimal(
        clientId: "veros_145b3a8f2a8f4dc59394cbbd0dd2a77f",
        redirectUri: "https://veros-web-oauth-demo.vercel.app/callback",
        userId:
            "vu-1ed0a927-a336-45dd-9c73-20092db9ae8d", // Empty userId for registration flow
      );

      final result = await VeryOauthSDK.authenticate(config);

      print('result: $result');

      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _status = '✅ Authentication successful!\n\ncode: ${result.code}';
        } else {
          String errorMessage;
          switch (result.error) {
            case OAuthErrorType.userCanceled:
              errorMessage = '⚠️ Authentication cancelled by user';
              break;
            case OAuthErrorType.verificationFailed:
              errorMessage = '❌ Verification failed---';
              break;
            case OAuthErrorType.registrationFailed:
              errorMessage = '❌ Registration failed111';
              break;
            case OAuthErrorType.timeout:
              errorMessage = '❌ Request timeout';
              break;
            case OAuthErrorType.networkError:
              errorMessage = '❌ Network error';
              break;
            default:
              errorMessage = '❌ Unknown error';
          }
          _status = errorMessage;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Error: $e';
      });
    }
  }
}
