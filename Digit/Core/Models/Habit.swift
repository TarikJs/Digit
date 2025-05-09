import Foundation

struct Habit: Identifiable, Codable, Equatable {
    let id: String
    let userId: String
    let title: String
    let createdAt: Date
    var completedDates: [Date]
    var preferredTime: PreferredHabitTime
    var currentStreak: Int
    var bestStreak: Int
    var lastCompletedDate: Date?
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        title: String,
        preferredTime: PreferredHabitTime,
        createdAt: Date = Date(),
        completedDates: [Date] = [],
        currentStreak: Int = 0,
        bestStreak: Int = 0,
        lastCompletedDate: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.preferredTime = preferredTime
        self.createdAt = createdAt
        self.completedDates = completedDates
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.lastCompletedDate = lastCompletedDate
    }
    
    // MARK: - Helper Methods
    
    var isCompletedToday: Bool {
        guard let lastCompleted = lastCompletedDate else { return false }
        return Calendar.current.isDate(lastCompleted, inSameDayAs: Date())
    }
    
    mutating func markCompleted() {
        let today = Date()
        completedDates.append(today)
        lastCompletedDate = today
        
        // Update streaks
        if let lastCompleted = completedDates.sorted().dropLast().last {
            let calendar = Calendar.current
            let daysBetween = calendar.dateComponents([.day], from: lastCompleted, to: today).day ?? 0
            
            if daysBetween <= 1 {
                currentStreak += 1
                bestStreak = max(currentStreak, bestStreak)
            } else {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
            bestStreak = 1
        }
    }
    
    mutating func markIncomplete() {
        guard let lastCompleted = lastCompletedDate,
              Calendar.current.isDate(lastCompleted, inSameDayAs: Date()) else { return }
        
        completedDates.removeAll { Calendar.current.isDate($0, inSameDayAs: Date()) }
        
        // Update last completed date to previous completion
        lastCompletedDate = completedDates.sorted().last
        
        // Update current streak
        if currentStreak > 0 {
            currentStreak -= 1
        }
    }
    
    var completionRate: Double {
        guard !completedDates.isEmpty else { return 0 }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: createdAt)
        let end = calendar.startOfDay(for: Date())
        let totalDays = calendar.dateComponents([.day], from: start, to: end).day ?? 1
        return Double(completedDates.count) / Double(max(1, totalDays))
    }
} 