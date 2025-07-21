//
//  IMDAConnectApp.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 29/5/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    @objc(userNotificationCenter:willPresentNotification:withCompletionHandler:) func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   willPresent notification: UNNotification,
                                   withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
           completionHandler([.banner, .sound])
       }
}

@main
struct IMDAConnectApp: App {
    @StateObject private var viewModel = AuthenticationViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if networkMonitor.isConnected {
                    NavigationView {
                        ContentView()
                            .environmentObject(viewModel)
                    }
                } else {
                    NoConnectionView()
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notifications granted.")
            } else {
                print("❌ Notifications denied or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
