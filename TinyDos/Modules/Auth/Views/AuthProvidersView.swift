import SwiftUI
import AuthenticationServices

struct AuthProvidersView: View {
    @Binding var email: String
    var isEmailValid: Bool
    @Binding var isLogin: Bool
    var isLoading: Bool
    var onEmailContinue: () -> Void
    var onApple: () -> Void
    var onGoogle: () -> Void
    var onFacebook: () -> Void
    @Binding var password: String
    
    var body: some View {
        let buttonHeight: CGFloat = 56
        VStack(spacing: 16) {
            // Email sign-in section (restored for App Store compliance)
            VStack(spacing: 12) {
                TextField("Email address", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 16)
                    .frame(height: buttonHeight)
                    .background(Color.digitGrayLight)
                    .cornerRadius(10)
                    .accessibilityLabel(LocalizedStringKey("auth_email_accessibility_label"))
                    .accessibilityHint(LocalizedStringKey("auth_email_accessibility_hint"))
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 16)
                    .frame(height: buttonHeight)
                    .background(Color.digitGrayLight)
                    .cornerRadius(10)
                    .accessibilityLabel(LocalizedStringKey("auth_password_accessibility_label"))
                    .accessibilityHint(LocalizedStringKey("auth_password_accessibility_hint"))
                
                // Password strength indicator (sign up only)
                if !isLogin {
                    PasswordStrengthBar(password: password)
                }
                
                Button(action: { onEmailContinue() }) {
                    Text(isLogin ? "Log in" : "Sign up")
                        .font(.plusJakartaSans(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: buttonHeight)
                        .background(Color.digitAccentRed)
                        .foregroundColor(isEmailValid && !isLoading ? .white : .white.opacity(0.5))
                        .cornerRadius(10)
                }
                .disabled(!isEmailValid || password.isEmpty || isLoading)
                .accessibilityLabel(isLogin ? LocalizedStringKey("auth_login_accessibility_label") : LocalizedStringKey("auth_signup_accessibility_label"))
            }
            .frame(width: 320)
            .padding(.bottom, 16)
            HStack(alignment: .center) {
                Spacer(minLength: 0)
                Rectangle()
                    .fill(Color.digitBrand.opacity(0.18))
                    .frame(height: 1)
                Spacer(minLength: 8)
                Text("or")
                    .font(.plusJakartaSans(size: 17, weight: .medium))
                    .foregroundStyle(Color.digitBrand.opacity(0.7))
                    .padding(.horizontal, 12)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                Spacer(minLength: 8)
                Rectangle()
                    .fill(Color.digitBrand.opacity(0.18))
                    .frame(height: 1)
                Spacer(minLength: 0)
            }
            .padding(.vertical, 8)
        }
        .frame(width: 320)
        
        VStack(spacing: 20) {
            HStack(spacing: 24) {
                // Apple Sign-In Button (circular, logo only, per HIG)
                Button(action: onApple) {
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                        Image(systemName: "applelogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                    }
                }
                .accessibilityLabel("Continue with Apple")
                .disabled(isLoading)
                // Google Sign-In Button (circular)
                Button(action: onGoogle) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 56, height: 56)
                            .overlay(
                                Circle()
                                    .stroke(Color.digitBrand.opacity(0.10), lineWidth: 1.5)
                            )
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                        Image("Google")
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
                }
                .accessibilityLabel("Continue with Google")
                .disabled(isLoading)
            }

            // Facebook Sign-In Button (commented out for now)
            /*
            Button(action: onFacebook) {
                Image("FacebookButton")
                    .resizable()
                    .scaledToFit()
                    .frame(height: buttonHeight)
            }
            .frame(width: 320)
            .background(Color.white)
            .cornerRadius(12)
            .accessibilityLabel("Continue with Facebook")
            .disabled(isLoading)
            */
        }
    }
}

struct PasswordStrengthBar: View {
    let password: String
    private var strength: Double {
        // Score: 0 (empty), 0.25 (weak), 0.5 (ok), 0.75 (good), 1.0 (strong)
        let lengthScore = min(Double(password.count) / 12.0, 1.0)
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSymbol = password.rangeOfCharacter(from: CharacterSet.punctuationCharacters.union(.symbols)) != nil
        let bonus = (hasNumber ? 0.15 : 0) + (hasSymbol ? 0.1 : 0)
        if password.isEmpty { return 0 }
        if password.count < 5 { return 0.15 }
        return min(lengthScore + bonus, 1.0)
    }
    private var barColor: Color {
        switch strength {
        case 0..<0.25: return .red
        case 0.25..<0.5: return .orange
        case 0.5..<0.75: return .yellow
        case 0.75..<0.95: return .green.opacity(0.7)
        default: return .green
        }
    }
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.digitGrayLight)
                    .frame(height: 8)
                Capsule()
                    .fill(barColor)
                    .frame(width: geo.size.width * strength, height: 8)
            }
        }
        .frame(height: 8)
        .padding(.horizontal, 2)
        .padding(.top, 2)
        .accessibilityLabel("Password strength indicator")
    }
}

#if DEBUG
#Preview {
    AuthProvidersView(
        email: .constant(""),
        isEmailValid: false,
        isLogin: .constant(true),
        isLoading: false,
        onEmailContinue: {},
        onApple: {},
        onGoogle: {},
        onFacebook: {},
        password: .constant("")
    )
}
#endif 