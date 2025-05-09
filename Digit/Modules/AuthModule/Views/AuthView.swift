import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var isLogin = true
    @EnvironmentObject private var coordinator: AuthCoordinator
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            if viewModel.isWaitingForVerification {
                WaitingForEmailVerificationView(onCancel: {
                    viewModel.stopVerificationPolling()
                    viewModel.isWaitingForVerification = false
                })
            } else {
                VStack(spacing: 32) {
                    Spacer()
                    // App Icon in circular mask
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.brand.opacity(0.1), lineWidth: 1)
                        )
                        .accessibilityHidden(true)
                    
                    Text("Log in or sign up")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.brand)
                        .accessibilityAddTraits(.isHeader)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .transition(.opacity)
                    }
                    
                    AuthProvidersView(
                        email: $viewModel.email,
                        isEmailValid: viewModel.isEmailValid,
                        isLogin: $isLogin,
                        isLoading: viewModel.isLoading,
                        onEmailContinue: { viewModel.continueWithEmail() },
                        onApple: { viewModel.continueWithApple() },
                        onGoogle: { viewModel.continueWithGoogle() },
                        onFacebook: { viewModel.continueWithFacebook() }
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
                                    .foregroundStyle(Color.brand)
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: isLogin)
                    }
                    .frame(width: 320)
                    Spacer()
                }
                
                if viewModel.isLoading {
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
                .foregroundStyle(Color.brand)
            Text("Check your email")
                .font(.title)
                .fontWeight(.bold)
            Text("We've sent you a link to verify your email. Please tap the link in your inbox to continue.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.brand)
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.body)
                    .foregroundStyle(.red)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background.ignoresSafeArea())
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#if DEBUG
#Preview {
    AuthView()
        .environmentObject(AuthCoordinator())
}
#endif 