import Foundation

protocol AwardRepositoryProtocol {
    func fetchAwards() async throws -> [Award]
    func addAward(_ award: Award) async throws
    func updateAward(_ award: Award) async throws
    func deleteAward(_ award: Award) async throws
}

final class AwardRepository: AwardRepositoryProtocol {
    private let localStore: AwardLocalStoreProtocol
    // Optionally add a remoteService if you have one for awards
    
    init(localStore: AwardLocalStoreProtocol = AwardLocalStore()) {
        self.localStore = localStore
    }
    
    func fetchAwards() async throws -> [Award] {
        let cached = try await localStore.fetchAwards()
        // TODO: Optionally sync with remote service in background
        return cached
    }
    func addAward(_ award: Award) async throws {
        try await localStore.saveAward(award)
        // TODO: Optionally sync with remote service
    }
    func updateAward(_ award: Award) async throws {
        try await localStore.saveAward(award)
        // TODO: Optionally sync with remote service
    }
    func deleteAward(_ award: Award) async throws {
        try await localStore.deleteAward(award)
        // TODO: Optionally sync with remote service
    }
} 