import SwiftUI

final class StatsViewModel: ObservableObject {
    // MARK: - Dependencies
    private let habitService: HabitServiceProtocol
    private let progressService: HabitProgressServiceProtocol
    private let userId: UUID
    
    // MARK: - Published Properties
    @Published var selectedPeriod: Period = .week {
        didSet {
            Task { await loadStats() }
        }
    }
    @Published var barChartData: [DayStat] = []
    @Published var perfectCount: Int = 0
    @Published var partialCount: Int = 0
    @Published var missedCount: Int = 0
    @Published var summaryStats: [HabitStat] = []
    @Published var calendarData: [HabitCalendarData] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var overallCompletionRate: Int = 0
    @Published var avgChartCompletionRate: Int = 0
    
    // MARK: - Internal State
    private var habits: [Habit] = []
    
    // MARK: - Init
    init(habitService: HabitServiceProtocol, progressService: HabitProgressServiceProtocol, userId: UUID) {
        self.habitService = habitService
        self.progressService = progressService
        self.userId = userId
        Task { await loadStats() }
    }
    
    // MARK: - Period Enum
    enum Period: CaseIterable, Equatable, Identifiable {
        case week, month, year
        var id: Self { self }
        var title: String {
            switch self {
            case .week: return "7 days"
            case .month: return "30 days"
            case .year: return "1 year"
            }
        }
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
    }
    
    struct DayStat: Identifiable, Equatable {
        let id = UUID()
        let date: Date
        let percent: Double // 0.0...1.0
    }
    struct HabitCalendarData: Identifiable {
        let id: UUID
        let icon: String
        let title: String
        let percentCompleted: Int
        let days: [HabitCalendarDay]
    }
    struct HabitCalendarDay: Identifiable {
        let id = UUID()
        let date: Date
        let progress: Int
        let goal: Int
        let isActive: Bool
    }
    
    // MARK: - Period Title
    var periodTitle: String {
        let now = Date()
        let calendar = Calendar.current
        switch selectedPeriod {
        case .week:
            let start = calendar.date(byAdding: .day, value: -6, to: now) ?? now
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
        case .month:
            let formatter = DateFormatter()
            formatter.dateFormat = "LLLL yyyy"
            return formatter.string(from: now)
        case .year:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            return formatter.string(from: now)
        }
    }
    
    // MARK: - Navigation
    func goToPreviousPeriod() {
        // TODO: Implement period navigation if needed
    }
    func goToNextPeriod() {
        // TODO: Implement period navigation if needed
    }
    
    // MARK: - Data Loading
    private func loadStats() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        do {
            let habits = try await habitService.fetchHabits()
            self.habits = habits
            let now = Date()
            let calendar = Calendar.current
            let startDate = calendar.date(byAdding: .day, value: -(selectedPeriod.days - 1), to: now) ?? now
            // For bar chart: aggregate completion per day across all habits
            var dailyCompletion: [Date: Double] = [:]
            // For summary row
            var perfect = 0, partial = 0, missed = 0
            // For summary cards
            var summary: [HabitStat] = []
            // For calendar cards
            var calendarCards: [HabitCalendarData] = []
            // For overall completion rate
            var totalCompletedHabitDays = 0
            let totalTrackedHabitDays = habits.count * 90
            for habit in habits {
                let habitId = habit.id
                let progressList = try await progressService.fetchProgressForRange(userId: userId, habitId: habitId, startDate: startDate, endDate: now)
                // For summary row
                perfect += progressList.filter { $0.progress >= $0.goal && $0.goal > 0 }.count
                partial += progressList.filter { $0.progress > 0 && $0.progress < $0.goal }.count
                missed += progressList.filter { $0.progress == 0 }.count
                // For summary cards
                let completedCount = progressList.filter { $0.progress >= $0.goal && $0.goal > 0 }.count
                summary.append(HabitStat(
                    icon: habit.icon,
                    title: habit.name,
                    value: "\(completedCount) done",
                    color: .digitHabitGreen
                ))
                // For bar chart: sum percent per day
                for progress in progressList {
                    let day = calendar.startOfDay(for: progress.date)
                    let percent = progress.goal > 0 ? min(Double(progress.progress) / Double(progress.goal), 1.0) : 0.0
                    dailyCompletion[day, default: 0.0] += percent
                }
                // For calendar cards: from habit.createdAt (or 90 days ago, whichever is later) to today
                let calendarStart = calendar.date(byAdding: .day, value: -89, to: now) ?? now
                var days: [HabitCalendarDay] = []
                for i in 0..<90 {
                    let date = calendar.date(byAdding: .day, value: i, to: calendarStart) ?? calendarStart
                    if date < habit.createdAt {
                        days.append(HabitCalendarDay(date: date, progress: 0, goal: 0, isActive: false))
                    } else if let progress = progressList.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                        days.append(HabitCalendarDay(date: date, progress: progress.progress, goal: progress.goal, isActive: true))
                    } else {
                        days.append(HabitCalendarDay(date: date, progress: 0, goal: habit.dailyGoal, isActive: true))
                    }
                }
                let activeDays = days.filter { $0.isActive }
                let completedHabitDays = activeDays.filter { $0.progress >= $0.goal && $0.goal > 0 }.count
                let percentCompleted = activeDays.count > 0 ? Int((Double(completedHabitDays) / Double(activeDays.count)) * 100) : 0
                calendarCards.append(HabitCalendarData(id: habit.id, icon: habit.icon, title: habit.name, percentCompleted: percentCompleted, days: days))
            }
            let overallCompletionRate = totalTrackedHabitDays > 0 ? Int((Double(totalCompletedHabitDays) / Double(totalTrackedHabitDays)) * 100) : 0
            // Calculate average daily completion rate for the chart
            let periodDays = selectedPeriod.days
            var dailyCompletionRates: [Double] = []
            for i in 0..<periodDays {
                let day = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -(periodDays - 1 - i), to: now) ?? now)
                var completedHabits = 0
                var trackedHabits = 0
                for habit in habits {
                    // Find progress for this habit on this day
                    if let progress = try? await progressService.fetchProgressForRange(userId: userId, habitId: habit.id, startDate: day, endDate: day).first {
                        trackedHabits += 1
                        if progress.goal > 0 && progress.progress >= progress.goal {
                            completedHabits += 1
                        }
                    } else {
                        // No record: treat as 0 progress
                        trackedHabits += 1
                    }
                }
                let percent = trackedHabits > 0 ? Double(completedHabits) / Double(trackedHabits) : 0.0
                dailyCompletionRates.append(percent)
            }
            let avgCompletionRate = dailyCompletionRates.count > 0 ? Int((dailyCompletionRates.reduce(0, +) / Double(dailyCompletionRates.count)) * 100) : 0
            // Normalize bar chart data: average percent per day
            var barChart: [DayStat] = []
            for i in 0..<selectedPeriod.days {
                let day = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -(selectedPeriod.days - 1 - i), to: now) ?? now)
                let value = dailyCompletion[day] ?? 0.0
                barChart.append(DayStat(date: day, percent: value / Double(max(habits.count, 1))))
            }
            let barChartCopy = barChart
            let perfectCopy = perfect
            let partialCopy = partial
            let missedCopy = missed
            let summaryCopy = summary
            let calendarCopy = calendarCards
            await MainActor.run {
                self.barChartData = barChartCopy
                self.perfectCount = perfectCopy
                self.partialCount = partialCopy
                self.missedCount = missedCopy
                self.summaryStats = summaryCopy
                self.calendarData = calendarCopy
                self.overallCompletionRate = overallCompletionRate
                self.avgChartCompletionRate = avgCompletionRate
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func deleteHabit(id: UUID) async {
        isLoading = true
        errorMessage = nil
        do {
            try await habitService.deleteHabit(id: id)
            await loadStats()
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to delete habit: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
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