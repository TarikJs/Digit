import Foundation

protocol HabitProgressServiceProtocol {
    func fetchProgress(userId: UUID, habitId: UUID, date: Date) async throws -> HabitProgress?
    func upsertProgress(progress: HabitProgress) async throws
    func fetchProgressForRange(userId: UUID, habitId: UUID, startDate: Date, endDate: Date) async throws -> [HabitProgress]
    func fetchAllProgress() async throws -> [HabitProgress]
    func addProgress(_ progress: HabitProgress) async throws
    func updateProgress(_ progress: HabitProgress) async throws
    func deleteProgress(_ progress: HabitProgress) async throws
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

    private func utcMidnight(for date: Date) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.startOfDay(for: date)
    }

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()

    func fetchProgress(userId: UUID, habitId: UUID, date: Date) async throws -> HabitProgress? {
        let utcDate = utcMidnight(for: date)
        let dateString = Self.dateFormatter.string(from: utcDate)
        print("📱 [DEBUG] fetchProgress REQUEST: userId=\(userId.uuidString), habitId=\(habitId.uuidString), date=\(dateString)")
        let response = try await SupabaseManager.shared.client
            .from("habit_progress")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("habit_id", value: habitId.uuidString)
            .eq("date", value: dateString)
            .single()
            .execute()
        let data = response.data
        print("🥣 [DEBUG] fetchProgress RAW RESPONSE: \(String(data: data, encoding: .utf8) ?? "<no data>")")
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        do {
            let progress = try decoder.decode(HabitProgress.self, from: data)
            print("📱 [DEBUG] fetchProgress DECODED: \(progress)")
            return progress
        } catch {
            print("📱 [DEBUG] fetchProgress DECODING ERROR: \(error)")
            return nil
        }
    }

    func upsertProgress(progress: HabitProgress) async throws {
        guard SupabaseManager.shared.client.auth.currentSession != nil else {
            print("📱 [DEBUG] Not authenticated: cannot upsert progress.")
            throw HabitProgressServiceError.notAuthenticated
        }
        print("📱 [DEBUG] upsertProgress REQUEST: userId=\(progress.userId), habitId=\(progress.habitId), date=\(Self.dateFormatter.string(from: utcMidnight(for: progress.date))), progress=\(progress.progress), goal=\(progress.goal)")
        let utcDate = utcMidnight(for: progress.date)
        let upsertRow = HabitProgressUpsert(
            id: progress.id,
            user_id: progress.userId,
            habit_id: progress.habitId,
            date: Self.dateFormatter.string(from: utcDate),
            progress: progress.progress,
            goal: progress.goal
        )
        print("📱 [DEBUG] upsertProgress UPSERT PAYLOAD: \(upsertRow)")
        do {
            let response = try await SupabaseManager.shared.client
                .from("habit_progress")
                .upsert(upsertRow, onConflict: "user_id,habit_id,date")
                .execute()
            let data = response.data
            print("🥣 [DEBUG] upsertProgress RAW RESPONSE: \(String(data: data, encoding: .utf8) ?? "<no data>")")
        } catch {
            print("📱 [DEBUG] upsertProgress ERROR: \(error)")
            throw error
        }
    }

    func fetchProgressForRange(userId: UUID, habitId: UUID, startDate: Date, endDate: Date) async throws -> [HabitProgress] {
        let utcStart = utcMidnight(for: startDate)
        let utcEnd = utcMidnight(for: endDate)
        let start = Self.dateFormatter.string(from: utcStart)
        let end = Self.dateFormatter.string(from: utcEnd)
        print("📱 [DEBUG] fetchProgressForRange REQUEST: userId=\(userId.uuidString), habitId=\(habitId.uuidString), start=\(start), end=\(end)")
        do {
            let response =
                start == end ?
                    try await SupabaseManager.shared.client
                        .from("habit_progress")
                        .select()
                        .eq("user_id", value: userId.uuidString)
                        .eq("habit_id", value: habitId.uuidString)
                        .eq("date", value: start)
                        .execute()
                :
                    try await SupabaseManager.shared.client
                        .from("habit_progress")
                        .select()
                        .eq("user_id", value: userId.uuidString)
                        .eq("habit_id", value: habitId.uuidString)
                        .gte("date", value: start)
                        .lte("date", value: end)
                        .execute()
            let data = response.data
            print("🥣 [DEBUG] fetchProgressForRange RAW RESPONSE: \(String(data: data, encoding: .utf8) ?? "<no data>")")
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            do {
                let progressList = try decoder.decode([HabitProgress].self, from: data)
                print("📱✅ [DEBUG] fetchProgressForRange DECODED: count=\(progressList.count)")
                for progress in progressList {
                    print("📱 [DEBUG] fetchProgressForRange ITEM: \(progress)")
                }
                return progressList
            } catch {
                print("📱❌ [DEBUG] fetchProgressForRange DECODING ERROR: \(error)")
                return []
            }
        } catch {
            print("📱❌ [DEBUG] fetchProgressForRange ERROR: \(error)")
            throw error
        }
    }

    func fetchAllProgress() async throws -> [HabitProgress] {
        // This is a placeholder. You should implement fetching all progress for the current user.
        // For now, return an empty array or throw if not supported.
        return []
    }

    func addProgress(_ progress: HabitProgress) async throws {
        try await upsertProgress(progress: progress)
    }

    func updateProgress(_ progress: HabitProgress) async throws {
        try await upsertProgress(progress: progress)
    }

    func deleteProgress(_ progress: HabitProgress) async throws {
        // Implement actual delete logic if needed
        // For now, throw not implemented
        throw NSError(domain: "HabitProgressService", code: -1, userInfo: [NSLocalizedDescriptionKey: "deleteProgress not implemented"])
    }
} 