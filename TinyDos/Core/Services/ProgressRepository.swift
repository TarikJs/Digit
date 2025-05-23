import Foundation

protocol ProgressRepositoryProtocol {
    func fetchProgress() async throws -> [HabitProgress]
    func addProgress(_ progress: HabitProgress) async throws
    func updateProgress(_ progress: HabitProgress) async throws
    func deleteProgress(_ progress: HabitProgress) async throws
}

final class ProgressRepository: ProgressRepositoryProtocol {
    private let localStore: ProgressLocalStoreProtocol
    private let remoteService: HabitProgressServiceProtocol
    
    init(localStore: ProgressLocalStoreProtocol = ProgressLocalStore(), remoteService: HabitProgressServiceProtocol = HabitProgressService()) {
        self.localStore = localStore
        self.remoteService = remoteService
    }
    
    func fetchProgress() async throws -> [HabitProgress] {
        let cached = try await localStore.fetchProgress()
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                let remote = try await self.remoteService.fetchAllProgress()
                try await self.localStore.saveProgressList(remote)
            } catch {
                // Optionally log error
            }
        }
        return cached
    }
    func addProgress(_ progress: HabitProgress) async throws {
        try await localStore.saveProgress(progress)
        Task.detached { [weak self] in
            try? await self?.remoteService.addProgress(progress)
        }
    }
    func updateProgress(_ progress: HabitProgress) async throws {
        try await localStore.saveProgress(progress)
        Task.detached { [weak self] in
            try? await self?.remoteService.updateProgress(progress)
        }
    }
    func deleteProgress(_ progress: HabitProgress) async throws {
        try await localStore.deleteProgress(progress)
        Task.detached { [weak self] in
            try? await self?.remoteService.deleteProgress(progress)
        }
    }
} 