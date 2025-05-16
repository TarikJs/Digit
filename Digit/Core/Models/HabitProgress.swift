import Foundation

struct HabitProgress: Identifiable, Codable, Equatable {
    // Use String for all IDs to match Supabase JSON
    let id: String
    let userId: String
    let habitId: String
    let date: Date
    var progress: Int
    var goal: Int
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case habitId = "habit_id"
        case date
        case progress
        case goal
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // Custom decoding to handle different date formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        habitId = try container.decode(String.self, forKey: .habitId)
        progress = try container.decode(Int.self, forKey: .progress)
        goal = try container.decode(Int.self, forKey: .goal)
        // date: yyyy-MM-dd
        let dateString = try container.decode(String.self, forKey: .date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        guard let parsedDate = dateFormatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Date string does not match yyyy-MM-dd")
        }
        date = parsedDate
        // createdAt/updatedAt: ISO8601
        let isoFormatter = ISO8601DateFormatter()
        if let createdAtString = try? container.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = isoFormatter.date(from: createdAtString)
        } else {
            createdAt = nil
        }
        if let updatedAtString = try? container.decodeIfPresent(String.self, forKey: .updatedAt) {
            updatedAt = isoFormatter.date(from: updatedAtString)
        } else {
            updatedAt = nil
        }
    }

    // Internal initializer for in-memory and upsert use
    init(id: String, userId: String, habitId: String, date: Date, progress: Int, goal: Int, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.userId = userId
        self.habitId = habitId
        self.date = date
        self.progress = progress
        self.goal = goal
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Computed properties for UUIDs if needed elsewhere
    var idUUID: UUID? { UUID(uuidString: id) }
    var userIdUUID: UUID? { UUID(uuidString: userId) }
    var habitIdUUID: UUID? { UUID(uuidString: habitId) }
} 