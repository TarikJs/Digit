import Foundation
import Supabase

/// Errors that can occur in the HabitService.
enum HabitServiceError: Error, LocalizedError {
    case notAuthenticated
    case decodingError
    case encodingError
    case networkError(Error)
    case supabaseError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated."
        case .decodingError:
            return "Failed to decode data from the server."
        case .encodingError:
            return "Failed to encode data for the server."
        case .networkError(let error):
            return error.localizedDescription
        case .supabaseError(let message):
            return message
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

/// Service for managing habits via Supabase backend.
final class HabitService: HabitServiceProtocol {
    private let client: SupabaseClient
    private let table = "habits"

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    /// Fetches all habits for the current authenticated user.
    func fetchHabits() async throws -> [Habit] {
        guard let userId = try? await client.auth.session.user.id else {
            throw HabitServiceError.notAuthenticated
        }
        let response = try await client
            .from(table)
            .select()
            .eq("user_id", value: userId)
            .execute()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        // DEBUG: Print raw JSON response
        if let jsonString = String(data: response.data, encoding: .utf8) {
            print("[DEBUG] Habits JSON response: \n\(jsonString)")
        }
        do {
            let habits = try decoder.decode([Habit].self, from: response.data)
            return habits
        } catch {
            print("[DEBUG] Decoding error: \(error)")
            print("[DEBUG] Raw data: \(String(data: response.data, encoding: .utf8) ?? "<no data>")")
            throw error
        }
    }

    /// Adds a new habit for the current user.
    func addHabit(_ habit: Habit) async throws {
        _ = try await client
            .from(table)
            .insert([habit])
            .execute()
    }

    /// Updates an existing habit for the current user.
    func updateHabit(_ habit: Habit) async throws {
        _ = try await client
            .from(table)
            .update(habit)
            .eq("id", value: habit.id.uuidString)
            .execute()
    }

    /// Deletes a habit by its ID for the current user.
    func deleteHabit(id: UUID) async throws {
        _ = try await client
            .from(table)
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    func createHabit(_ habit: Habit) async throws {
        try await addHabit(habit)
    }
    
    func getCurrentHabit(for userId: String) async throws -> Habit? {
        let response = try await client
            .from(table)
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .limit(1)
            .execute()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        // DEBUG: Print raw JSON response
        if let jsonString = String(data: response.data, encoding: .utf8) {
            print("[DEBUG] getCurrentHabit JSON response: \n\(jsonString)")
        }
        do {
            let habits = try decoder.decode([Habit].self, from: response.data)
            return habits.first
        } catch {
            print("[DEBUG] Decoding error (getCurrentHabit): \(error)")
            print("[DEBUG] Raw data (getCurrentHabit): \(String(data: response.data, encoding: .utf8) ?? "<no data>")")
            throw error
        }
    }
    
    func deleteHabit(_ habitId: String) async throws {
        guard let uuid = UUID(uuidString: habitId) else { return }
        try await deleteHabit(id: uuid)
    }
} 