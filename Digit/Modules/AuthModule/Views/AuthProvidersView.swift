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
            // Email TextField and Continue/Signup button
            TextField("Email", text: $email)
                .font(.system(size: 24))
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .frame(height: 56)
                .background(Color.white)
                .foregroundStyle(Color.black)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.brand, lineWidth: 1.7)
                )
                .accessibilityLabel("Email")
                .disabled(isLoading)
            
            Button(action: onEmailContinue) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isLogin ? "Continue" : "Sign up")
                    }
                }
                .font(.system(size: 24))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isEmailValid && !isLoading ? Color.brand : Color.brand.opacity(0.5))
                .foregroundStyle(Color.white)
                .cornerRadius(12)
            }
            .disabled(!isEmailValid || isLoading)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isLogin)
        }
        .frame(width: 320)
        
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.brand.opacity(0.2))
            Text("or")
                .font(.system(size: 24))
                .foregroundStyle(Color(hex: "6B7280"))
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.brand.opacity(0.2))
        }
        .frame(width: 320)
        
        VStack(spacing: 12) {
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
                    .stroke(Color(hex: "747775"), lineWidth: 1)
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
            
            // Facebook Sign-In Button
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