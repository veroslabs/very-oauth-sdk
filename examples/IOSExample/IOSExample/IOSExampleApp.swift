//
//  IOSExampleApp.swift
//  IOSExample
//
//  Created by yan on 2025/10/10.
//

import SwiftUI
import VeryOauthSDK
import AVFoundation

@main
struct IOSExampleApp: App {
    
    init() {
        // Pre-request camera permission on app launch to avoid WebView prompts
        setupCameraPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    /// Setup camera permission to avoid repeated prompts in WebView
    private func setupCameraPermission() {
        // Initialize SDK
        let _ = VeryOauthSDK.shared
        
        // Check camera permission status
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        print("📷 Camera permission status on app launch: \(cameraStatus.rawValue)")
        
        // If permission is not determined, request it proactively
        if cameraStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                print("📷 Camera permission requested on app launch: \(granted ? "granted" : "denied")")
            }
        }
    }
}