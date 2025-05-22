import Foundation
import GoogleSignIn
import UIKit

/// Handles Google Sign-In and returns the ID token for authentication with Supabase.
final class GoogleSignInManager {
    static let shared = GoogleSignInManager()
    private init() {}

    /// Starts the Google sign-in flow and returns the ID token on success.
    /// - Returns: The Google ID token as a String.
    /// - Throws: An error if sign-in fails or the ID token is missing.
    func signIn(presentingViewController: UIViewController) async throws -> String {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as? String else {
            throw GoogleSignInError.missingClientID
        }
        let config = GIDConfiguration(clientID: clientID)
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.configuration = config
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    continuation.resume(throwing: GoogleSignInError.missingIDToken)
                    return
                }
                continuation.resume(returning: idToken)
            }
        }
    }
}

/// Errors that can occur during Google Sign-In.
enum GoogleSignInError: Error, LocalizedError {
    case missingClientID
    case missingIDToken

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Google Client ID is missing from Info.plist."
        case .missingIDToken:
            return "Google ID token is missing after sign-in."
        }
    }
} 