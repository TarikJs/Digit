import SwiftUI

enum AuthState {
    case auth
    case onboarding
    case waitingForVerification
    case main
}

final class AuthCoordinator: ObservableObject {
    @Published var currentState: AuthState = .auth
    let authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
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
    
    @MainActor
    func makeCurrentView() -> some View {
        switch currentState {
        case .auth:
            return AnyView(
                AuthView()
                    .environmentObject(self)
                    .environmentObject(authViewModel)
            )
        case .onboarding:
            let onboardingVM = OnboardingViewModel(
                email: authViewModel.email,
                isEmailVerified: false,
                authViewModel: authViewModel,
                onComplete: { [weak self] in
                    Task { [weak self] in
                        await self?.handleOnboardingCompletion()
                    }
                },
                onDismiss: { } // Temporary placeholder
            )
            onboardingVM.onDismiss = { [weak self, weak onboardingVM] in
                Task {
                    await onboardingVM?.deletePartialProfileIfAbandoned()
                    await MainActor.run {
                        withAnimation {
                            self?.currentState = .auth
                        }
                    }
                }
            }
            return AnyView(
                OnboardingView(viewModel: onboardingVM)
                    .onAppear {
                        Task { await onboardingVM.markProfileInWork() }
                    }
                    .environmentObject(self)
                    .environmentObject(authViewModel)
            )
        case .waitingForVerification:
            return AnyView(
                WaitingForEmailVerificationView(onCancel: { [weak self] in
                    Task { [weak self] in
                        await self?.handleVerificationCancel()
                    }
                }, onVerified: { [weak self] in
                    self?.currentState = .main
                })
                .environmentObject(self)
                .environmentObject(authViewModel)
            )
        case .main:
            return AnyView(
                MainTabView()
                    .environmentObject(self)
                    .environmentObject(authViewModel)
            )
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

extension AuthCoordinator {
    @MainActor
    func handleOnboardingCompletion() async {
            withAnimation {
                currentState = .main
        }
    }

    @MainActor
    func handleVerificationCancel() async {
        authViewModel.stopVerificationPolling()
        withAnimation {
            currentState = .auth
        }
    }
} 