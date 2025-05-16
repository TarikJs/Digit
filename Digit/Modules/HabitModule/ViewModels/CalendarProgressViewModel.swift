import Foundation
import SwiftUI

@MainActor
final class CalendarProgressViewModel: ObservableObject {
    // MARK: - Types
    struct DayCompletion: Identifiable {
        let id = UUID()
        let date: Date
        let progress: Int
        let goal: Int
        let isActive: Bool // true if habit existed and not in future
    }
    struct HabitCalendarData: Identifiable {
        let id: UUID
        let icon: String
        let title: String
        let startDate: Date
        let days: [DayCompletion]
        let percentCompleted: Int // 0...100
    }

    // MARK: - Published
    @Published var habits: [HabitCalendarData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let habitService: HabitServiceProtocol
    private let progressService: HabitProgressServiceProtocol
    private let userId: UUID
    private let calendar = Calendar.current

    // MARK: - Init
    init(habitService: HabitServiceProtocol, progressService: HabitProgressServiceProtocol, userId: UUID) {
        self.habitService = habitService
        self.progressService = progressService
        self.userId = userId
        Task { await loadCalendarData() }
    }

    // MARK: - Data Loading
    func loadCalendarData() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedHabits = try await habitService.fetchHabits()
            let today = calendar.startOfDay(for: Date())
            let startOfRange = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -89, to: today) ?? today)
            var habitCards: [HabitCalendarData] = []
            for habit in fetchedHabits {
                // Always use the full 90-day range for the grid
                let allDates: [Date] = (0...89).compactMap { offset in
                    calendar.date(byAdding: .day, value: offset, to: startOfRange).map { calendar.startOfDay(for: $0) }
                }
                let progressList = try await progressService.fetchProgressForRange(userId: userId, habitId: habit.id, startDate: startOfRange, endDate: today)
                var progressByDate: [Date: HabitProgress] = [:]
                for p in progressList { progressByDate[calendar.startOfDay(for: p.date)] = p }
                var dayCompletions: [DayCompletion] = []
                var completedScheduledDays = 0
                var totalScheduledDays = 0
                print("\n📅 Habit: \(habit.name) (")
                for date in allDates {
                    let isFuture = date > today
                    let isScheduled = isHabitScheduled(habit, on: date, today: today)
                    let progress = progressByDate[date]?.progress ?? 0
                    let goal = progressByDate[date]?.goal ?? habit.dailyGoal
                    let percent = (goal > 0) ? Double(progress) / Double(goal) : 0
                    if isScheduled && !isFuture {
                        totalScheduledDays += 1
                        if percent >= 1.0 { completedScheduledDays += 1 }
                    }
                    print("  • \(date): scheduled=\(isScheduled), progress=\(progress), goal=\(goal), percent=\(String(format: "%.2f", percent))")
                    dayCompletions.append(DayCompletion(date: date, progress: progress, goal: goal, isActive: isScheduled && !isFuture))
                }
                let percentCompleted = totalScheduledDays > 0 ? Int(round(Double(completedScheduledDays) / Double(totalScheduledDays) * 100)) : 0
                print("==> totalScheduledDays=\(totalScheduledDays), completedScheduledDays=\(completedScheduledDays), percentCompleted=\(percentCompleted)%\n")
                habitCards.append(HabitCalendarData(
                    id: habit.id,
                    icon: habit.icon,
                    title: habit.name,
                    startDate: habit.startDate,
                    days: dayCompletions,
                    percentCompleted: percentCompleted
                ))
            }
            self.habits = habitCards
        } catch {
            self.errorMessage = "Failed to load calendar data: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // Helper to determine if a habit is scheduled for a given date
    private func isHabitScheduled(_ habit: Habit, on date: Date, today: Date) -> Bool {
        let day = calendar.startOfDay(for: date)
        let start = calendar.startOfDay(for: habit.startDate)
        let end = habit.endDate != nil ? calendar.startOfDay(for: habit.endDate!) : today
        guard day >= start && day <= end && day <= today else { return false }
        switch habit.repeatFrequency.lowercased() {
        case "daily":
            return true
        case "weekly", "custom":
            if let weekdays = habit.weekdays {
                let weekday = calendar.component(.weekday, from: day) - 1 // 0=Sun, 6=Sat
                return weekdays.contains(weekday)
            }
            return true
        default:
            return true
        }
    }
} 