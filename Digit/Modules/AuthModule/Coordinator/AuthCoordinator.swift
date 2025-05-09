import SwiftUI

enum AuthState {
    case auth
    case onboarding
    case main
}

final class AuthCoordinator: ObservableObject {
    @Published var currentState: AuthState = .auth
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleProceedToMain), name: .proceedToMain, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleProceedToOnboarding), name: .proceedToOnboarding, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleProceedToMain() {
        proceedToMain()
    }
    
    @objc private func handleProceedToOnboarding() {
        proceedToOnboarding()
    }
    
    @ViewBuilder
    func makeCurrentView() -> some View {
        switch currentState {
        case .auth:
            AuthView()
                .environmentObject(self)
        case .onboarding:
            OnboardingView(viewModel: OnboardingViewModel(
                onComplete: { [weak self] in
                    withAnimation {
                        self?.currentState = .main
                    }
                },
                onDismiss: { [weak self] in
                    withAnimation {
                        self?.currentState = .auth
                    }
                }
            ))
            .environmentObject(self)
        case .main:
            MainTabView()
        }
    }
    
    func proceedToOnboarding() {
        withAnimation {
            currentState = .onboarding
        }
    }
    
    func proceedToMain() {
        withAnimation {
            currentState = .main
        }
    }
} 