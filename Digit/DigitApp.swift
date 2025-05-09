//
//  DigitApp.swift
//  Digit
//
//  Created by Tarik Zukic on 5/6/25.
//

import SwiftUI

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
    @StateObject private var coordinator = AuthCoordinator()
    
    var body: some Scene {
        WindowGroup {
            coordinator.makeCurrentView()
                .environmentObject(coordinator)
                .onOpenURL { url in
                    print("[DEBUG] Received deep link: \(url)")
                    SupabaseManager.shared.client.auth.handle(url)
                }
        }
    }
}
