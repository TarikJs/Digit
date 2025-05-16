import Foundation

struct HabitProgress: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: UUID
    let habitId: UUID
    let date: Date
    var progress: Int
    var goal: Int
    let createdAt: Date
    let updatedAt: Date

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
} 