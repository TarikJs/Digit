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
            let startOfRange = calendar.date(byAdding: .day, value: -89, to: today) ?? today
            var habitCards: [HabitCalendarData] = []
            for habit in fetchedHabits {
                let habitStart = max(habit.startDate, startOfRange)
                let daysCount = calendar.dateComponents([.day], from: habitStart, to: today).day ?? 0
                let allDates: [Date] = (0...daysCount).compactMap { offset in
                    calendar.date(byAdding: .day, value: offset, to: habitStart)
                }
                let progressList = try await progressService.fetchProgressForRange(userId: userId, habitId: habit.id, startDate: habitStart, endDate: today)
                var progressByDate: [Date: HabitProgress] = [:]
                for p in progressList { progressByDate[calendar.startOfDay(for: p.date)] = p }
                var dayCompletions: [DayCompletion] = []
                var completedDays = 0
                var totalActiveDays = 0
                for date in allDates {
                    let isFuture = date > today
                    let isActive = !isFuture && date >= calendar.startOfDay(for: habit.startDate)
                    let progress = progressByDate[date]?.progress ?? 0
                    let goal = progressByDate[date]?.goal ?? habit.dailyGoal
                    let percent = (goal > 0) ? Double(progress) / Double(goal) : 0
                    if isActive && !isFuture {
                        totalActiveDays += 1
                        if percent >= 1.0 { completedDays += 1 }
                    }
                    dayCompletions.append(DayCompletion(date: date, progress: progress, goal: goal, isActive: isActive))
                }
                let percentCompleted = totalActiveDays > 0 ? Int(round(Double(completedDays) / Double(totalActiveDays) * 100)) : 0
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
} 