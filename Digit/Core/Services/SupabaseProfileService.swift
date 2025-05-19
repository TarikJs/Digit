import Foundation
import Supabase

// MARK: - SupabaseProfileService
final class SupabaseProfileService: ProfileServiceProtocol {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    /// Fetches the current user's profile from Supabase 'profiles' table.
    func fetchProfile() async throws -> UserProfile {
        let session = try await client.auth.session
        let userId = session.user.id.uuidString
        let response = try await client
            .from("profiles")
            .select("*")
            .eq("id", value: userId)
            .single()
            .execute()
        do {
            let profile = try JSONDecoder().decode(UserProfile.self, from: response.data)
            return profile
        } catch {
            throw SupabaseError.unknown
        }
    }

    /// Updates the current user's profile in Supabase 'profiles' table.
    func updateProfile(_ profile: UserProfile) async throws {
        let session = try await client.auth.session
        guard session.user.id.uuidString == profile.id else {
            throw SupabaseError.invalidCredentials
        }
        let _ = try await client
            .from("profiles")
            .upsert(profile)
            .eq("id", value: profile.id)
            .execute()
    }
} 