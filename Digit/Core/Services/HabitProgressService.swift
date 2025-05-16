import Foundation

protocol HabitProgressServiceProtocol {
    func fetchProgress(userId: UUID, habitId: UUID, date: Date) async throws -> HabitProgress?
    func upsertProgress(progress: HabitProgress) async throws
    func fetchProgressForRange(userId: UUID, habitId: UUID, startDate: Date, endDate: Date) async throws -> [HabitProgress]
}

private struct HabitProgressUpsert: Encodable {
    let id: String
    let user_id: String
    let habit_id: String
    let date: String
    let progress: Int
    let goal: Int
}

enum HabitProgressServiceError: Error, LocalizedError {
    case notAuthenticated
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated."
        }
    }
}

final class HabitProgressService: HabitProgressServiceProtocol {
    init() {}

    func fetchProgress(userId: UUID, habitId: UUID, date: Date) async throws -> HabitProgress? {
        let dateString = Self.dateFormatter.string(from: date)
        let response = try await SupabaseManager.shared.client
            .from("habit_progress")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("habit_id", value: habitId.uuidString)
            .eq("date", value: dateString)
            .single()
            .execute()
        let data = response.data
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(HabitProgress.self, from: data)
    }

    func upsertProgress(progress: HabitProgress) async throws {
        guard let session = SupabaseManager.shared.client.auth.currentSession else {
            print("[DEBUG] Not authenticated: cannot upsert progress.")
            throw HabitProgressServiceError.notAuthenticated
        }
        print("[DEBUG] Authenticated as user: \(session.user.id)")
        print("[DEBUG] Progress userId: \(progress.userId)")
        let upsertRow = HabitProgressUpsert(
            id: progress.id.uuidString,
            user_id: progress.userId.uuidString,
            habit_id: progress.habitId.uuidString,
            date: Self.dateFormatter.string(from: progress.date),
            progress: progress.progress,
            goal: progress.goal
        )
        _ = try await SupabaseManager.shared.client
            .from("habit_progress")
            .upsert(upsertRow, onConflict: "user_id,habit_id,date")
            .execute()
    }

    func fetchProgressForRange(userId: UUID, habitId: UUID, startDate: Date, endDate: Date) async throws -> [HabitProgress] {
        let start = Self.dateFormatter.string(from: startDate)
        let end = Self.dateFormatter.string(from: endDate)
        let response = try await SupabaseManager.shared.client
            .from("habit_progress")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("habit_id", value: habitId.uuidString)
            .gte("date", value: start)
            .lte("date", value: end)
            .execute()
        let data = response.data
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([HabitProgress].self, from: data)) ?? []
    }

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()
} 