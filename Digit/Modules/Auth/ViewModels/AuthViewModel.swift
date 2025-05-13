import Foundation
import Supabase
import SwiftUI
import AuthenticationServices

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isWaitingForVerification: Bool = false
    @Published var currentUserProfile: UserProfile? = nil
    
    // Track sign-in attempts
    private var lastSignInAttempt: Date?
    private let minimumSignInInterval: TimeInterval = 60 // 1 minute cooldown
    private var verificationTimer: Timer?
    
    var isEmailValid: Bool {
        // Improved email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func continueWithEmail() {
        guard isEmailValid else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        // Rate limiting
        if let lastAttempt = lastSignInAttempt,
           Date().timeIntervalSince(lastAttempt) < minimumSignInInterval {
            let remainingTime = Int(minimumSignInInterval - Date().timeIntervalSince(lastAttempt))
            errorMessage = "Please wait \(remainingTime) seconds before trying again"
            return
        }
        
        isLoading = true
        errorMessage = nil
        lastSignInAttempt = Date()
        
        let normalizedEmail = email.lowercased()
        
        Task {
            do {
                // Check if profile exists for this email
                let response = try await SupabaseManager.shared.client
                    .from("profiles")
                    .select("*")
                    .eq("email", value: normalizedEmail)
                    .execute()
                
                let profiles = (try? JSONDecoder().decode([UserProfile].self, from: response.data)) ?? []
                
                if !profiles.isEmpty {
                    // Existing user: login
                    _ = try await SupabaseManager.shared.client.auth.signInWithOTP(
                        email: normalizedEmail,
                        shouldCreateUser: false
                    )
                    // Show waiting for verification screen
                    isWaitingForVerification = true
                    startVerificationPolling()
                } else {
                    // New user: signup
                    _ = try await SupabaseManager.shared.client.auth.signInWithOTP(
                        email: normalizedEmail,
                        shouldCreateUser: true
                    )
                    // Show waiting for verification screen
                    isWaitingForVerification = true
                    startVerificationPolling()
                }
                
                // Show a generic message for both flows
                errorMessage = "Please check your email for a login or confirmation link."
            } catch {
                errorMessage = "An error occurred. Please try again later."
            }
            isLoading = false
        }
    }
    
    func continueWithGoogle() {
        Task { await handlePostSignIn() }
    }
    
    func continueWithApple() {
        isLoading = true
        errorMessage = nil
        AppleSignInCoordinator.shared.signIn { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let idToken):
                    print("Apple ID Token: \(idToken)") // Debug print
                    do {
                        let credentials = OpenIDConnectCredentials(
                            provider: .apple,
                            idToken: idToken,
                            nonce: nil
                        )
                        let session = try await SupabaseManager.shared.client.auth.signInWithIdToken(credentials: credentials)
                        print("Supabase session: \(session)") // Debug print
                        await self?.handlePostSignIn()
                    } catch {
                        print("Supabase sign-in error: \(error)") // Debug print
                        self?.errorMessage = error.localizedDescription
                        self?.isLoading = false
                    }
                case .failure(let error):
                    print("Apple Sign In Error: \(error)") // Debug print
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    func continueWithFacebook() {
        Task { await handlePostSignIn() }
    }
    
    // Check if user profile exists, and route accordingly
    func handlePostSignIn() async {
        defer { isLoading = false }
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let userId = session.user.id.uuidString
            print("[DEBUG] Fetching profile for userId: \(userId)")
            let response = try await SupabaseManager.shared.client
                .from("profiles")
                .select("*")
                .eq("id", value: userId)
                .execute()
            print("[DEBUG] Supabase response: \(String(data: response.data, encoding: .utf8) ?? "nil")")
            if let profiles = try? JSONDecoder().decode([UserProfile].self, from: response.data),
               let profile = profiles.first {
                print("[DEBUG] Decoded profile: \(profile)")
                await MainActor.run {
                    self.currentUserProfile = profile
                }
                NotificationCenter.default.post(name: .proceedToMain, object: nil)
                return
            } else {
                print("[DEBUG] No profile found or decoding failed.")
            }
            NotificationCenter.default.post(name: .proceedToOnboarding, object: nil)
        } catch {
            print("[DEBUG] Error checking profile: \(error)")
            NotificationCenter.default.post(name: .proceedToOnboarding, object: nil)
        }
    }

    func startVerificationPolling() {
        verificationTimer?.invalidate()
        verificationTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    let session = try await SupabaseManager.shared.client.auth.session
                    let user = session.user
                    if user.email != nil {
                        // Optionally, check for email confirmation if your backend supports it
                        await MainActor.run {
                            self.isWaitingForVerification = false
                            self.verificationTimer?.invalidate()
                        }
                        NotificationCenter.default.post(name: .proceedToOnboarding, object: nil)
                    }
                } catch {
                    // Ignore errors, keep polling
                }
            }
        }
    }

    func stopVerificationPolling() {
        Task { @MainActor in
            verificationTimer?.invalidate()
            verificationTimer = nil
        }
    }
}

// MARK: - Apple Sign In Coordinator
final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate {
    static let shared = AppleSignInCoordinator()
    private var completion: ((Result<String, Error>) -> Void)?
    
    func signIn(completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            completion?(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch Apple identity token."])))
            return
        }
        completion?(.success(idToken))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(.failure(error))
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let proceedToOnboarding = Notification.Name("proceedToOnboarding")
    static let proceedToMain = Notification.Name("proceedToMain")
}

/// UserProfile is used for both encoding (upsert) and decoding (fetch) from Supabase.
struct UserProfile: Codable {
    let id: String
    let email: String
    let first_name: String
    let last_name: String
    let date_of_birth: String
    let gender: String
    let created_at: String?
    // Add other fields as needed
}

// Add SupabaseError enum for better error handling
enum SupabaseError: Error {
    case rateLimitExceeded
    case invalidCredentials
    case networkError
    case unknown
} 