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
            // Apple Sign-In Button
            SignInWithAppleButton(
                .continue,
                onRequest: { _ in },
                onCompletion: { _ in
                    print("🍏 [DEBUG] SignInWithAppleButton tapped and onCompletion called")
                    onApple()
                }
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