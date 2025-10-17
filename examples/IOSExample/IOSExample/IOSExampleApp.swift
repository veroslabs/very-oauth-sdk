//
//  IOSExampleApp.swift
//  IOSExample
//
//  Created by yan on 2025/10/10.
//

import SwiftUI

@main
struct IOSExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    // Handle URL schemes for OAuth callback
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // This will be handled by ASWebAuthenticationSession automatically
        print("Received URL: \(url)")
        return true
    }
}
