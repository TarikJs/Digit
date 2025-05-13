import SwiftUI

final class StatsViewModel: ObservableObject {
    // MARK: - Period Enum
    enum Period: CaseIterable, Equatable {
        case week, month, year
        var title: String {
            switch self {
            case .week: return "7 days"
            case .month: return "30 days"
            case .year: return "1 year"
            }
        }
    }
    
    // MARK: - Published Properties
    @Published var selectedPeriod: Period = .month
    @Published var chartData: [Int] = [1, 5, 7, 7, 6, 9, 8, 7, 10, 8, 7, 6, 5, 4, 6, 8, 7, 5, 4, 6, 7, 8, 7, 6, 5, 4, 5, 6, 7, 8]
    @Published var summaryStats: [HabitStat] = [
        .init(icon: "book.closed", title: "Read book", value: "70 pages", color: .digitHabitPurple),
        .init(icon: "bed.double.fill", title: "Wake up at 9:00", value: "20 times", color: .digitHabitGreen),
        .init(icon: "dumbbell", title: "Work out", value: "15 times", color: .digitHabitGreen),
        .init(icon: "brain.head.profile", title: "Meditation 30 min", value: "8 times", color: .digitHabitPurple)
    ]
    
    // For weekly grid
    let weeklyHabits: [String] = [
        "Run 25 min", "Read book", "Wake up at 9:00", "Work out", "Meditation 30 min", "Drink water", "No cigarettes"
    ]
    let weekDays: [String] = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    // MARK: - Period Title
    var periodTitle: String {
        switch selectedPeriod {
        case .week:
            return "5 - 11 Oct 2024"
        case .month:
            return "June 2024"
        case .year:
            return "2024"
        }
    }
    
    // MARK: - Navigation
    func goToPreviousPeriod() {
        // For demo, do nothing
    }
    func goToNextPeriod() {
        // For demo, do nothing
    }
}

// MARK: - Habit Stat Model
struct HabitStat: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let value: String
    let color: Color
} 