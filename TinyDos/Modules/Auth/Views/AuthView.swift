import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLogin = true
    @EnvironmentObject private var coordinator: AuthCoordinator
    @State private var rememberMe = false
    @FocusState private var focusedField: Field?
    @State private var showPassword: Bool = false
    @State private var showErrorAlert: Bool = false
    
    enum Field: Hashable {
        case email, password
    }
    
    var body: some View {
        ZStack {
            Color.digitGrayLight.ignoresSafeArea()
            
            if coordinator.currentState == .waitingForVerification {
                WaitingForEmailVerificationView(onCancel: {
                    Task { await coordinator.handleVerificationCancel() }
                }, onVerified: {
                    coordinator.proceedToMain()
                })
            } else {
                VStack {
                    Spacer(minLength: 0)
                    // Add extra top padding to move content away from the notch
                    VStack(spacing: 0) {
                        // Onboarding Carousel (image height 220pt)
                        AuthOnboardingCarousel(imageHeight: 220)
                            .padding(.bottom, 16)
                        // Error message (animated, triggers alert)
                        if let error = authViewModel.errorMessage, !error.isEmpty {
                            Color.clear.frame(height: 0) // For animation placeholder
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showErrorAlert = true
                                    }
                                }
                        }
                        // Email & Password Fields
                        VStack(spacing: 18) {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.digitBrand)
                                TextField("Email address", text: $authViewModel.email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .font(.system(size: 17, weight: .regular, design: .rounded))
                                    .accessibilityLabel("Email address")
                                    .focused($focusedField, equals: .email)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.04), radius: 2, y: 1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .email ? Color.digitAccentRed : Color.clear, lineWidth: 1.5)
                            )
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.digitBrand)
                                Group {
                                    if showPassword {
                                        TextField("Password", text: $authViewModel.password)
                                            .font(.system(size: 17, weight: .regular, design: .rounded))
                                            .accessibilityLabel("Password")
                                            .focused($focusedField, equals: .password)
                                    } else {
                                        SecureField("Password", text: $authViewModel.password)
                                            .font(.system(size: 17, weight: .regular, design: .rounded))
                                            .accessibilityLabel("Password")
                                            .focused($focusedField, equals: .password)
                                    }
                                }
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                        .accessibilityLabel(showPassword ? "Hide password" : "Show password")
                                }
                                .padding(.leading, 4)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.04), radius: 2, y: 1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .password ? Color.digitAccentRed : Color.clear, lineWidth: 1.5)
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        // Remember Me & Forgot Password
                        HStack {
                            Button(action: { rememberMe.toggle() }) {
                                HStack(spacing: 6) {
                                    Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                        .foregroundColor(rememberMe ? .digitAccentRed : .gray)
                                    Text("Remember me")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Remember me")
                    Spacer()
                            Button(action: { /* TODO: Forgot password action */ }) {
                                Text("Forgot Password ?")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.digitAccentRed)
                            }
                            .accessibilityLabel("Forgot Password")
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        // Log In Button
                        Button(action: { authViewModel.continueWithEmail(isLogin: isLogin) }) {
                            Text(isLogin ? "Log In" : "Sign Up")
                                .font(.system(size: 19, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color.digitAccentRed)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 22)
                        .padding(.bottom, 8)
                        .disabled(!authViewModel.isEmailValid || authViewModel.password.isEmpty || authViewModel.isLoading)
                        // Divider with 'or login with'
                        HStack {
                            Rectangle()
                                .fill(Color(hex: "6B7280"))
                                .frame(height: 1)
                            Text("Or")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "6B7280"))
                                .padding(.horizontal, 10)
                            Rectangle()
                                .fill(Color(hex: "6B7280"))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        // Social Buttons (circular, side by side)
                        HStack(spacing: 20) {
                            // Google Sign-In Button
                            Button(action: { authViewModel.continueWithGoogle() }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 48, height: 48)
                                        .shadow(color: Color.black.opacity(0.08), radius: 2, y: 1)
                                    Image("Google")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                            }
                            .accessibilityLabel("Sign in with Google")
                            // Apple Sign-In Button (icon only)
                            Button(action: { authViewModel.continueWithApple() }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 48, height: 48)
                                        .shadow(color: Color.black.opacity(0.08), radius: 2, y: 1)
                                    Image(systemName: "applelogo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 24)
                                        .foregroundColor(.white)
                                }
                            }
                            .accessibilityLabel("Sign in with Apple")
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        // Sign Up / Log In Toggle
                        HStack(spacing: 6) {
                            Text(isLogin ? "Don't have an account?" : "Already have an account?")
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "6B7280"))
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    isLogin.toggle()
                                }
                            }) {
                                Text(isLogin ? "Sign Up" : "Log In")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.digitBrand)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                    .padding(.top, 48)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 24)
                    .frame(maxWidth: 480)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                .safeAreaInset(edge: .bottom) { Spacer().frame(height: 24) }
                .alert(isPresented: $showErrorAlert) {
                    Alert(
                        title: Text("Warning"),
                        message: Text(authViewModel.errorMessage ?? "Unknown error"),
                        dismissButton: .default(Text("OK")) {
                            authViewModel.errorMessage = nil
                }
                    )
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
    var onVerified: () -> Void
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var isPolling = false
    @State private var resendStatus: String? = nil
    @State private var isResending = false
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "envelope.open")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(Color.digitBrand)
            Text("Check your email")
                .font(.plusJakartaSans(size: 24, weight: .bold))
            Text("We've sent you a link to verify your email. Please tap the link in your inbox to continue.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.digitBrand)
            if let resendStatus = resendStatus {
                Text(resendStatus)
                    .font(.plusJakartaSans(size: 14))
                    .foregroundStyle(.secondary)
            }
            Button(action: {
                isResending = true
                resendStatus = nil
                Task {
                    await authViewModel.resendVerificationEmail()
                    isResending = false
                    resendStatus = authViewModel.errorMessage == nil ? "Verification email resent!" : authViewModel.errorMessage
                }
            }) {
                if isResending {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("Resend verification email")
                        .font(.body)
                        .foregroundStyle(Color.digitBrand)
                }
            }
            .disabled(isResending)
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.body)
                    .foregroundStyle(.red)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.digitBackground.ignoresSafeArea())
        .onAppear {
            guard !isPolling else { return }
            isPolling = true
            authViewModel.pollForEmailVerification {
                onVerified()
            }
        }
        .onDisappear {
            authViewModel.stopVerificationPolling()
        }
    }
}

// MARK: - Onboarding Carousel
struct AuthOnboardingCarousel: View {
    @State private var currentPage = 0
    private let pages: [(image: String, title: String, subtitle: String)] = [
        ("Wearable Tech 1", "Welcome to TinyDos", "We believe the world is more beautiful as each person gets better. Yep, that's you."),
        ("Wearable Tech 3", "Track Your Habits", "Stay on top of your goals with daily reminders and progress tracking."),
        ("Zero Tasks 3", "Celebrate Progress", "Earn awards and see your growth as you build better habits.")
    ]
    let imageHeight: CGFloat
    init(imageHeight: CGFloat) {
        self.imageHeight = imageHeight
    }
    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \ .self) { idx in
                    VStack(spacing: 0) {
                        Image(pages[idx].image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: imageHeight)
                            .padding(.bottom, 8)
                        Text(pages[idx].title)
                            .font(.custom("PlusJakartaSans-ExtraBold", size: 24))
                            .foregroundStyle(Color.digitBrand)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 4)
                        Text(pages[idx].subtitle)
                            .font(.plusJakartaSans(size: 16))
                            .foregroundStyle(Color(hex: "6B7280"))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 300)
            // Custom small dots below the carousel
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { idx in
                    Circle()
                        .fill(idx == currentPage ? Color.digitBrand : Color.digitBrand.opacity(0.18))
                        .frame(width: 6, height: 6)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                        .accessibilityLabel(idx == currentPage ? "Current page" : "Page \(idx + 1)")
                }
            }
            .padding(.top, 8)
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

