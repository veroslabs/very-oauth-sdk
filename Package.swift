// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "VeryOauthSDK",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "VeryOauthSDK",
            targets: ["VeryOauthSDK"]
        )
    ],
    dependencies: [
        // No external dependencies
    ],
    targets: [
        .target(
            name: "VeryOauthSDK",
            dependencies: [],
            path: "ios/VeryOauthSDK"
        )
    ],
    swiftLanguageVersions: [.v5]
)
