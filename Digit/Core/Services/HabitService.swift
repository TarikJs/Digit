import Foundation
import Supabase

protocol HabitServiceProtocol {
    func createHabit(_ habit: Habit) async throws
    func getCurrentHabit(for userId: String) async throws -> Habit?
    func updateHabit(_ habit: Habit) async throws
    func deleteHabit(_ habitId: String) async throws
}

final class HabitService: HabitServiceProtocol {
    private let supabase = SupabaseManager.shared.client
    private let tableName = "habits"
    
    func createHabit(_ habit: Habit) async throws {
        _ = try await supabase
            .from(tableName)
            .insert(habit)
            .execute()
    }
    
    func getCurrentHabit(for userId: String) async throws -> Habit? {
        let query = supabase
            .from(tableName)
            .select()
            .eq("userId", value: userId)
            .order("createdAt", ascending: false)
            .limit(1)
        
        let response: [Habit] = try await query.execute().value
        return response.first
    }
    
    func updateHabit(_ habit: Habit) async throws {
        _ = try await supabase
            .from(tableName)
            .update(habit)
            .eq("id", value: habit.id)
            .execute()
    }
    
    func deleteHabit(_ habitId: String) async throws {
        _ = try await supabase
            .from(tableName)
            .delete()
            .eq("id", value: habitId)
            .execute()
    }
} 