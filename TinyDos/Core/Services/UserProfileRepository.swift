import Foundation

protocol UserProfileRepositoryProtocol {
    func fetchProfile() async throws -> UserProfile?
    func saveProfile(_ profile: UserProfile) async throws
    func deleteProfile(_ profile: UserProfile) async throws
}

final class UserProfileRepository: UserProfileRepositoryProtocol, ProfileServiceProtocol {
    private let localStore: UserProfileLocalStoreProtocol
    private let remoteService: SupabaseProfileService
    
    init(localStore: UserProfileLocalStoreProtocol = UserProfileLocalStore(), remoteService: SupabaseProfileService = SupabaseProfileService()) {
        self.localStore = localStore
        self.remoteService = remoteService
    }
    
    // MARK: - UserProfileRepositoryProtocol Implementation
    func fetchProfile() async throws -> UserProfile? {
        let cached = try await localStore.fetchProfile()
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                let remote = try await self.remoteService.fetchProfile()
                try await self.localStore.saveProfile(remote)
            } catch {
                // Optionally log error
            }
        }
        return cached
    }
    
    func saveProfile(_ profile: UserProfile) async throws {
        try await localStore.saveProfile(profile)
        Task.detached { [weak self] in
            try? await self?.remoteService.updateProfile(profile)
        }
    }
    
    func deleteProfile(_ profile: UserProfile) async throws {
        try await localStore.deleteProfile(profile)
        // If you want to support remote deletion, implement deleteProfile in SupabaseProfileService and call it here.
        // Task.detached { [weak self] in
        //     try? await self?.remoteService.deleteProfile(profile)
        // }
    }
    
    // MARK: - ProfileServiceProtocol Implementation
    func fetchProfile() async throws -> UserProfile {
        // First try to get from remote
        do {
            return try await remoteService.fetchProfile()
        } catch {
            // If remote fails, try local
            if let local = try await localStore.fetchProfile() {
                return local
            }
            // If both fail, throw error
            throw NSError(domain: "UserProfileRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch profile"])
        }
    }
    
    func updateProfile(_ profile: UserProfile) async throws {
        try await saveProfile(profile)
    }
} 