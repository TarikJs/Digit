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
            // First decode to an intermediate DTO that matches the database schema
            let dto = try JSONDecoder().decode(ProfileDTO.self, from: response.data)
            // Convert DTO to our domain model
            return dto.toDomain()
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
        // Convert domain model to DTO for database storage
        let dto = ProfileDTO(from: profile)
        let _ = try await client
            .from("profiles")
            .upsert(dto)
            .eq("id", value: profile.id)
            .execute()
    }
}

// MARK: - Data Transfer Objects
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
    
    init(from profile: UserProfile) {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        self.id = profile.id
        self.email = profile.email
        self.first_name = profile.firstName
        self.last_name = profile.lastName
        self.user_name = profile.userName
        self.date_of_birth = profile.dateOfBirth.map { dateFormatter.string(from: $0) }
        self.gender = profile.gender
        self.created_at = profile.createdAt.map { dateFormatter.string(from: $0) }
        self.region = profile.region
        self.setup_comp = profile.setupComp
    }
} 