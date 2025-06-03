import Foundation

protocol HabitRepositoryProtocol {
    func fetchHabits() async throws -> [Habit]
    func addHabit(_ habit: Habit) async throws
    func updateHabit(_ habit: Habit) async throws
    func deleteHabit(_ habit: Habit) async throws
    func syncHabitsWithServer() async throws
}

final class HabitRepository: HabitRepositoryProtocol {
    private let localStore: HabitLocalStoreProtocol
    private let remoteService: HabitServiceProtocol
    
    init(localStore: HabitLocalStoreProtocol = HabitLocalStore(), remoteService: HabitServiceProtocol = HabitService()) {
        self.localStore = localStore
        self.remoteService = remoteService
    }
    
    func fetchHabits() async throws -> [Habit] {
        // 1. Return cached data immediately
        let cached = try await localStore.fetchHabits()
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                let remote = try await self.remoteService.fetchHabits()
                try await self.localStore.saveHabits(remote)
            } catch {
                // Optionally log error
            }
        }
        return cached
    }
    func addHabit(_ habit: Habit) async throws {
        try await localStore.saveHabit(habit)
        Task.detached { [weak self] in
            try? await self?.remoteService.addHabit(habit)
        }
    }
    func updateHabit(_ habit: Habit) async throws {
        try await localStore.saveHabit(habit)
        Task.detached { [weak self] in
            try? await self?.remoteService.updateHabit(habit)
        }
    }
    func deleteHabit(_ habit: Habit) async throws {
        try await localStore.deleteHabit(habit)
        Task.detached { [weak self] in
            try? await self?.remoteService.deleteHabit(id: habit.id)
        }
    }
    // MARK: - Two-way Sync
    /// Syncs local and remote habits: uploads local-only habits, caches remote-only habits, and clears cache for new accounts.
    func syncHabitsWithServer() async throws {
        let localHabits = try await localStore.fetchHabits()
        let remoteHabits = try await remoteService.fetchHabits()
        let localIds = Set(localHabits.map { $0.id })
        let remoteIds = Set(remoteHabits.map { $0.id })

        // 1. Upload local-only habits to server
        let localOnly = localHabits.filter { !remoteIds.contains($0.id) }
        for habit in localOnly {
            try await remoteService.addHabit(habit)
        }

        // 2. Cache remote-only habits locally
        let remoteOnly = remoteHabits.filter { !localIds.contains($0.id) }
        for habit in remoteOnly {
            try await localStore.saveHabit(habit)
        }

        // 3. If server is empty (new account), clear local cache
        if remoteHabits.isEmpty && !localHabits.isEmpty {
            for habit in localHabits {
                try await localStore.deleteHabit(habit)
            }
        }
    }
} 