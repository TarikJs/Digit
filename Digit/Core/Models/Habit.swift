import Foundation

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