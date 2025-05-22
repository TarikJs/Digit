import Foundation

/// Protocol defining CRUD operations for managing habits via a backend service (e.g., Supabase).
protocol HabitServiceProtocol {
    /// Fetches all habits for the current authenticated user.
    func fetchHabits() async throws -> [Habit]
    /// Adds a new habit for the current user.
    func addHabit(_ habit: Habit) async throws
    /// Updates an existing habit for the current user.
    func updateHabit(_ habit: Habit) async throws
    /// Deletes a habit by its ID for the current user.
    func deleteHabit(id: UUID) async throws
    /// Fetches the most recent habit for a given user.
    func getCurrentHabit(for userId: String) async throws -> Habit?
} 