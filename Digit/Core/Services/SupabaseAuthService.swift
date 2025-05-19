import Foundation
import Supabase

/// Production AuthService for Supabase sign-out
final class SupabaseAuthService: AuthServiceProtocol {
    func signOut() async throws {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
        } catch {
            throw error
        }
    }
} 