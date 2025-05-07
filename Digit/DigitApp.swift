//
//  DigitApp.swift
//  Digit
//
//  Created by Tarik Zukic on 5/6/25.
//

import SwiftUI

// MARK: - AppViewModel

final class AppViewModel: ObservableObject {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    @Published var showOnboarding: Bool = false
    
    init() {
        showOnboarding = !hasCompletedOnboarding
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        showOnboarding = false
    }
}

// MARK: - AppCoordinator

struct AppCoordinator: View {
    @StateObject private var appViewModel = AppViewModel()

    var body: some View {
        Group {
            if appViewModel.showOnboarding {
                OnboardingView(viewModel: OnboardingViewModel(onComplete: appViewModel.completeOnboarding))
            } else {
                MainTabView()
            }
        }
        .environmentObject(appViewModel)
    }
}

// MARK: - App Entry Point

@main
struct DigitApp: App {
    var body: some Scene {
        WindowGroup {
            AppCoordinator()
        }
    }
}
