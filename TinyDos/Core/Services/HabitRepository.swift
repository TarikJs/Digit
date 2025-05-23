import Foundation

protocol HabitRepositoryProtocol {
    func fetchHabits() async throws -> [Habit]
    func addHabit(_ habit: Habit) async throws
    func updateHabit(_ habit: Habit) async throws
    func deleteHabit(_ habit: Habit) async throws
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
} 