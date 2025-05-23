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
    @Published var password: String = ""
    
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
    
    func isEmailVerified() async -> Bool {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            return session.user.emailConfirmedAt != nil
        } catch {
            return false
        }
    }
    
    func continueWithEmail(isLogin: Bool) {
        Task {
            if isLogin {
                await signInWithEmailPassword()
            } else {
                await signUpWithEmailPassword()
            }
        }
    }
    
    func continueWithGoogle() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                // Find the top-most view controller for presentation
                guard let rootVC = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .flatMap({ $0.windows })
                    .first(where: { $0.isKeyWindow })?.rootViewController else {
                    throw GoogleSignInError.missingClientID // Use as generic error
                }
                let idToken = try await GoogleSignInManager.shared.signIn(presentingViewController: rootVC)
                let credentials = OpenIDConnectCredentials(
                    provider: .google,
                    idToken: idToken,
                    nonce: nil
                )
                _ = try await SupabaseManager.shared.client.auth.signInWithIdToken(credentials: credentials)
                await handlePostSignIn()
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func continueWithApple() {
        print("🍏 [DEBUG] continueWithApple() called")
        isLoading = true
        errorMessage = nil
        AppleSignInCoordinator.shared.signIn { [weak self] result in
            print("🍏 [DEBUG] AppleSignInCoordinator completion handler called")
            Task { @MainActor in
                switch result {
                case .success(let idToken):
                    print("🍏 [DEBUG] Apple ID Token received: \(idToken.prefix(12))...")
                    do {
                        let credentials = OpenIDConnectCredentials(
                            provider: .apple,
                            idToken: idToken,
                            nonce: nil
                        )
                        let session = try await SupabaseManager.shared.client.auth.signInWithIdToken(credentials: credentials)
                        print("🍏 [DEBUG] Supabase session: \(session)")
                        await self?.handlePostSignIn()
                    } catch {
                        print("🍏 [DEBUG] Supabase sign-in error: \(error)")
                        self?.errorMessage = error.localizedDescription
                        self?.isLoading = false
                    }
                case .failure(let error):
                    print("🍏 [DEBUG] Apple Sign In Error: \(error)")
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
            
            // Decode to DTO first
            if let profiles = try? JSONDecoder().decode([ProfileDTO].self, from: response.data),
               let profileDTO = profiles.first {
                print("[DEBUG] Decoded profile: \(profileDTO)")
                await MainActor.run {
                    self.currentUserProfile = profileDTO.toDomain()
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

    func pollForEmailVerification(completion: @escaping () -> Void) {
        verificationTimer?.invalidate()
        verificationTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    let session = try await SupabaseManager.shared.client.auth.session
                    let user = session.user
                    if user.emailConfirmedAt != nil {
                        await MainActor.run {
                            self.verificationTimer?.invalidate()
                            completion()
                        }
                    }
                } catch {
                    // Ignore errors, keep polling
                }
            }
        }
    }

    func signUpWithEmailPassword() async {
        guard isEmailValid else {
            errorMessage = "Please enter a valid email address."
            return
        }
        // Password must be at least 6 characters, at least 2 letters, at least 2 numbers
        let letterCount = password.reduce(0) { $0 + ($1.isLetter ? 1 : 0) }
        let numberCount = password.reduce(0) { $0 + ($1.isNumber ? 1 : 0) }
        guard password.count >= 6, letterCount >= 2, numberCount >= 2 else {
            errorMessage = "Password must be at least 6 characters, with at least 2 letters and 2 numbers."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let session = try await SupabaseManager.shared.client.auth.signUp(email: email, password: password)
            // Insert partial profile with setup_comp = "N"
            let userId = session.user.id.uuidString
            let partialProfileDTO = ProfileDTO(
                id: userId,
                email: email,
                first_name: "",
                last_name: "",
                user_name: nil,
                date_of_birth: nil,
                gender: "",
                created_at: nil,
                region: nil,
                setup_comp: "N"
            )
            do {
                _ = try await SupabaseManager.shared.client
                    .from("profiles")
                    .upsert(partialProfileDTO)
                    .execute()
            } catch {
                print("[DEBUG] Failed to insert partial profile: \(error)")
            }
            NotificationCenter.default.post(name: .proceedToOnboarding, object: nil)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signInWithEmailPassword() async {
        guard isEmailValid else {
            errorMessage = "Please enter a valid email address."
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Please enter your password."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            _ = try await SupabaseManager.shared.client.auth.signIn(email: email, password: password)
            await handlePostSignIn()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func resendVerificationEmail() async {
        do {
            try await SupabaseManager.shared.client.auth.resend(
                email: self.email,
                type: .signup,
                emailRedirectTo: nil,
                captchaToken: nil
            )
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to resend verification email. Please try again later."
            }
        }
    }

    func deleteCurrentUserProfileIfNotComplete() async {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let userId = session.user.id.uuidString
            _ = try await SupabaseManager.shared.client
                .from("profiles")
                .delete()
                .eq("id", value: userId)
                .neq("setup_comp", value: "Y")
                .execute()
        } catch {
            print("[DEBUG] Failed to delete partial profile: \(error)")
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
    let firstName: String
    let lastName: String
    let userName: String?
    let dateOfBirth: Date?
    let gender: String
    let createdAt: Date?
    let region: String?
    let setupComp: String?
    // Add other fields as needed
}

// Add SupabaseError enum for better error handling
enum SupabaseError: Error {
    case rateLimitExceeded
    case invalidCredentials
    case networkError
    case unknown
}

// MARK: - Data Transfer Object
private struct ProfileDTO: Codable {
    let id: String
    let email: String
    let first_name: String
    let last_name: String
    let user_name: String?
    let date_of_birth: String?
    let gender: String
    let created_at: String?
    let region: String?
    let setup_comp: String?
    
    func toDomain() -> UserProfile {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let createdAtDate = created_at.flatMap { dateFormatter.date(from: $0) }
        let dateOfBirthDate = date_of_birth.flatMap { dateFormatter.date(from: $0) }
        
        return UserProfile(
            id: id,
            email: email,
            firstName: first_name,
            lastName: last_name,
            userName: user_name,
            dateOfBirth: dateOfBirthDate,
            gender: gender,
            createdAt: createdAtDate,
            region: region,
            setupComp: setup_comp
        )
    }
} 