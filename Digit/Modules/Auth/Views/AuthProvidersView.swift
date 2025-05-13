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
    
    var body: some View {
        VStack(spacing: 16) {
            // Removed email TextField and Continue/Signup button
        }
        .frame(width: 320)
        
        VStack(spacing: 12) {
            // Continue with Email Button
            Button(action: onEmailContinue) {
                HStack {
                    Image(systemName: "envelope")
                        .font(.system(size: 20, weight: .medium))
                    Text("Continue with Email")
                        .font(.system(size: 20, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(width: 320, height: 56)
                .foregroundStyle(Color.digitBrand)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.digitBrand, lineWidth: 1.7)
                )
                .cornerRadius(12)
            }
            .accessibilityLabel("Continue with Email")
            .disabled(isLoading)
            // Google Sign-In Button
            Button(action: onGoogle) {
                Image("GoogleLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 56)
            }
            .frame(width: 320)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.digitBrand, lineWidth: 1.7)
            )
            .cornerRadius(12)
            .accessibilityLabel("Sign in with Google")
            .disabled(isLoading)
            // Apple Sign-In Button
            SignInWithAppleButton(
                .continue,
                onRequest: { _ in },
                onCompletion: { _ in onApple() }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(width: 320, height: 56)
            .cornerRadius(12)
            .accessibilityLabel("Continue with Apple")
            .disabled(isLoading)
            // Facebook Sign-In Button (commented out for now)
            /*
            Button(action: onFacebook) {
                Image("FacebookButton")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 56)
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
        onFacebook: {}
    )
}
#endif 