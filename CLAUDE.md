# very-oauth-sdk

VeryOauthSDK: native OAuth 2.0 sign-in SDKs for "Sign in with Very" on iOS and
Android (system browser session or WebView, with camera permission support for
the in-WebView palm flow), plus a Flutter plugin.

## Layout

- `ios/VeryOauthSDK/` — Swift SDK source (`VeryOauthSDK.swift`, `VerySDK.h`).
- `Package.swift` (root) — SwiftPM package pointing at `ios/VeryOauthSDK`.
- `ios/VeryOauthSDK.podspec` — the podspec CI lints and pushes. A second
  `VeryOauthSDK.podspec` at the repo root is not used by CI; keep versions in sync.
- `android/` — Gradle project; library module `android/veryoauthsdk`
  (Kotlin, namespace `com.veryoauthsdk`, Maven `org.very:veryoauthsdk`).
  `android/gradle/wrapper/gradle-wrapper.jar` is not committed, so use Gradle 8.7
  directly (`gradle ...` from `android/`) or regenerate the wrapper.
- `flutter/` — Flutter plugin wrapping the native SDKs.
- `examples/` — `AndroidExample`, `IOSExample` (Swift), `IOSExampleOC`, etc.

## Build & Test

Mirrors `.github/workflows/ci.yml`:

```bash
# Android (JDK 17, Gradle 8.7)
cd android && gradle :veryoauthsdk:testDebugUnitTest

# iOS (macOS)
xcodebuild build -scheme VeryOauthSDK -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
```

## Releases

Tag-driven: pushing a `v*` tag runs
- `android-release.yml` — build/test, dokka, Maven publish, and creates the
  single GitHub release;
- `ios-release.yml` — `pod spec lint` + `pod trunk push` of `ios/VeryOauthSDK.podspec`.

Bump the version in `android/veryoauthsdk/build.gradle` (`versionName` and
publication `version`) and both podspecs before tagging.

## Rules

- Never skip tests; fix the root cause.
- Work on branches and open PRs; merge only with Tian's approval (admin override is fine when he says so).
- Conventional commits, with Linear IDs (e.g. `VER-123`) when there is one.
