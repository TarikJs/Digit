//
//  DigitApp.swift
//  Digit
//
//  Created by Tarik Zukic on 5/6/25.
//

import SwiftUI
import UIKit

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

final class AppCoordinator: ObservableObject, SplashCoordinatorDelegate {
    @Published var showSplash: Bool = true
    @Published var showOnboarding: Bool = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    let splashCoordinator = SplashCoordinator()

    init() {
        splashCoordinator.delegate = self
        showOnboarding = !hasCompletedOnboarding
    }

    func splashDidFinish() {
        withAnimation {
            showSplash = false
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        showOnboarding = false
    }
}

// MARK: - App Entry Point

@main
struct DigitApp: App {
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var coordinator: AuthCoordinator

    init() {
        let authViewModel = AuthViewModel()
        _authViewModel = StateObject(wrappedValue: authViewModel)
        _coordinator = StateObject(wrappedValue: AuthCoordinator(authViewModel: authViewModel))
        setupTabBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            coordinator.makeCurrentView()
                .environmentObject(coordinator)
                .environmentObject(authViewModel)
                .onOpenURL { url in
                    print("[DEBUG] Received deep link: \(url)")
                    SupabaseManager.shared.client.auth.handle(url)
                }
        }
    }
}
