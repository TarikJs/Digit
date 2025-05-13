import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLogin = true
    @EnvironmentObject private var coordinator: AuthCoordinator
    
    var body: some View {
        ZStack {
            Color.digitBackground
                .ignoresSafeArea()
            
            if authViewModel.isWaitingForVerification {
                WaitingForEmailVerificationView(onCancel: {
                    authViewModel.stopVerificationPolling()
                    authViewModel.isWaitingForVerification = false
                })
            } else {
                VStack(spacing: 32) {
                    Spacer()
                    // Onboarding Carousel
                    AuthOnboardingCarousel()
                    
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .transition(.opacity)
                    }
                    
                    AuthProvidersView(
                        email: $authViewModel.email,
                        isEmailValid: authViewModel.isEmailValid,
                        isLogin: $isLogin,
                        isLoading: authViewModel.isLoading,
                        onEmailContinue: { authViewModel.continueWithEmail() },
                        onApple: { authViewModel.continueWithApple() },
                        onGoogle: { authViewModel.continueWithGoogle() },
                        onFacebook: { authViewModel.continueWithFacebook() }
                    )
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Text(isLogin ? "New to Digit?" : "Already have an account?")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(hex: "6B7280"))
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    isLogin.toggle()
                                }
                            }) {
                                Text(isLogin ? "Sign up" : "Log in")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.digitBrand)
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: isLogin)
                    }
                    .frame(width: 320)
                    Spacer()
                }
                
                if authViewModel.isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
        }
        .preferredColorScheme(.light)
        .onReceive(NotificationCenter.default.publisher(for: .proceedToOnboarding)) { _ in
            coordinator.proceedToOnboarding()
        }
        .onReceive(NotificationCenter.default.publisher(for: .proceedToMain)) { _ in
            coordinator.proceedToMain()
        }
    }
}

struct WaitingForEmailVerificationView: View {
    var onCancel: () -> Void
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "envelope.open")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(Color.digitBrand)
            Text("Check your email")
                .font(.title)
                .fontWeight(.bold)
            Text("We've sent you a link to verify your email. Please tap the link in your inbox to continue.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.digitBrand)
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.body)
                    .foregroundStyle(.red)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.digitBackground.ignoresSafeArea())
    }
}

// MARK: - Onboarding Carousel
struct AuthOnboardingCarousel: View {
    @State private var currentPage = 0
    private let pages: [(image: String, title: String, subtitle: String)] = [
        ("Wearable Tech 1", "Welcome to Digit", "We believe the world is more beautiful as each person gets better. Yep, that's you."),
        ("Wearable Tech 3", "Track Your Habits", "Stay on top of your goals with daily reminders and progress tracking."),
        ("Zero Tasks 3", "Celebrate Progress", "Earn awards and see your growth as you build better habits.")
    ]
    var body: some View {
        VStack(spacing: 24) {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \ .self) { idx in
                    VStack(spacing: 0) {
                        Image(pages[idx].image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 220)
                            .padding(.bottom, 8)
                        Text(pages[idx].title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.digitBrand)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 4)
                        Text(pages[idx].subtitle)
                            .font(.system(size: 16))
                            .foregroundStyle(Color(hex: "6B7280"))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 340)
            // Dots
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \ .self) { idx in
                    Circle()
                        .fill(idx == currentPage ? Color.digitBrand : Color.digitBrand.opacity(0.2))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    let mockAuthViewModel = AuthViewModel()
    AuthView()
        .environmentObject(AuthCoordinator(authViewModel: mockAuthViewModel))
        .environmentObject(mockAuthViewModel)
}
#endif 