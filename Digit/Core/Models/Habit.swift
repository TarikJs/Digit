import Foundation

// MARK: - Postgres DateFormatter Extensions
extension DateFormatter {
    static let postgresTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSXXXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    static let postgresTimestampNoMillis: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ssXXXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

/// Represents a habit tracked by the user, matching the Supabase habits table schema.
struct Habit: Identifiable, Codable, Equatable {
    // MARK: - Properties
    /// Unique identifier for the habit (UUID, primary key)
    let id: UUID
    /// The user ID this habit belongs to (UUID, foreign key)
    let userId: UUID
    /// Name of the habit
    let name: String
    /// Optional description of the habit
    let description: String?
    /// Daily goal (e.g., number of repetitions)
    let dailyGoal: Int
    /// SF Symbol or custom icon name
    let icon: String
    /// The date the habit starts
    let startDate: Date
    /// The date the habit ends (optional)
    let endDate: Date?
    /// Repeat frequency (e.g., "daily", "weekly", "custom")
    let repeatFrequency: String
    /// Optional array of weekdays for custom repeat (0=Sun, 6=Sat)
    let weekdays: [Int]?
    /// Optional reminder time as a string ("HH:mm:ss")
    let reminderTime: String?
    /// Timestamp when the habit was created
    let createdAt: Date
    /// Timestamp when the habit was last updated
    let updatedAt: Date

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name = "habit_name"
        case description
        case dailyGoal = "daily_goal"
        case icon
        case startDate = "start_date"
        case endDate = "end_date"
        case repeatFrequency = "repeat_frequency"
        case weekdays
        case reminderTime = "reminder_time"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // Custom Decodable implementation to handle multiple date formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        dailyGoal = try container.decode(Int.self, forKey: .dailyGoal)
        icon = try container.decode(String.self, forKey: .icon)
        repeatFrequency = try container.decode(String.self, forKey: .repeatFrequency)
        weekdays = try container.decodeIfPresent([Int].self, forKey: .weekdays)
        reminderTime = try container.decodeIfPresent(String.self, forKey: .reminderTime)

        func decodeDate(forKey key: CodingKeys) throws -> Date {
            let string = try container.decode(String.self, forKey: key)
            // Try ISO8601 with fractional seconds and timezone offset
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withColonSeparatorInTimeZone]
            if let date = isoFormatter.date(from: string) {
                return date
            }
            // Try Postgres with millis
            if let date = DateFormatter.postgresTimestamp.date(from: string) {
                return date
            }
            // Try Postgres without millis
            if let date = DateFormatter.postgresTimestampNoMillis.date(from: string) {
                return date
            }
            throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Invalid date format: \(string)")
        }

        startDate = try decodeDate(forKey: .startDate)
        // endDate is optional
        if let endDateString = try container.decodeIfPresent(String.self, forKey: .endDate) {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withColonSeparatorInTimeZone]
            endDate = isoFormatter.date(from: endDateString)
                ?? DateFormatter.postgresTimestamp.date(from: endDateString)
                ?? DateFormatter.postgresTimestampNoMillis.date(from: endDateString)
        } else {
            endDate = nil
        }
        createdAt = try decodeDate(forKey: .createdAt)
        updatedAt = try decodeDate(forKey: .updatedAt)
    }

    init(
        id: UUID = UUID(),
        userId: UUID,
        name: String,
        description: String? = nil,
        dailyGoal: Int,
        icon: String,
        startDate: Date = Date(),
        endDate: Date? = nil,
        repeatFrequency: String,
        weekdays: [Int]? = nil,
        reminderTime: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.dailyGoal = dailyGoal
        self.icon = icon
        self.startDate = startDate
        self.endDate = endDate
        self.repeatFrequency = repeatFrequency
        self.weekdays = weekdays
        self.reminderTime = reminderTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
} 