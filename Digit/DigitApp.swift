//
//  TinyDosApp.swift
//  TinyDos
//
//  Created by Tarik Zukic on 5/6/25.
//

import SwiftUI
import UIKit

// MARK: - Orientation Lock AppDelegate
class PortraitAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK: - Tab Bar Appearance Setup
private func setupTabBarAppearance() {
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor(red: 1, green: 0.984, blue: 0.976, alpha: 1) // #FFFBF9
    appearance.shadowColor = UIColor(red: 35/255, green: 64/255, blue: 154/255, alpha: 0.12) // digitBrand with 12% opacity
    UITabBar.appearance().standardAppearance = appearance
    if #available(iOS 15.0, *) {
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - AppCoordinator

final class AppCoordinator: ObservableObject {
    @Published var showOnboarding: Bool = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    init() {
        showOnboarding = !hasCompletedOnboarding
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        showOnboarding = false
    }
}

// MARK: - App Entry Point

@main
struct TinyDosApp: App {
    @UIApplicationDelegateAdaptor(PortraitAppDelegate.self) var appDelegate
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var authCoordinator: AuthCoordinator

    init() {
        setupTabBarAppearance()
        let coordinator = AuthCoordinator(authViewModel: authViewModel)
        _authCoordinator = StateObject(wrappedValue: coordinator)
    }
    
    var body: some Scene {
        WindowGroup {
            authCoordinator.makeCurrentView()
                .environmentObject(authCoordinator)
                .environmentObject(authViewModel)
                .environment(\.font, .plusJakartaSans(size: 17))
                .onOpenURL { url in
                    print("[DEBUG] Received deep link: \(url)")
                    SupabaseManager.shared.client.auth.handle(url)
                }
                .preferredColorScheme(.light)
        }
    }
}
