//
//  HabitDetailViewModel.swift
//  Digit
//
//  ViewModel for a single habit's detail view.
//

import Foundation
import SwiftUI

final class HabitDetailViewModel: ObservableObject {
    @Published private(set) var habit: Habit
    private let onUpdate: (Habit) -> Void
    private let onDelete: () -> Void
    
    init(habit: Habit, onUpdate: @escaping (Habit) -> Void, onDelete: @escaping () -> Void) {
        self.habit = habit
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
    
    // MARK: - Completion Logic
    func isCompleted(on date: Date) -> Bool {
        habit.completions.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }
    
    func toggleCompletion(on date: Date) {
        if isCompleted(on: date) {
            habit.completions.removeAll { Calendar.current.isDate($0, inSameDayAs: date) }
        } else {
            habit.completions.append(date)
        }
        onUpdate(habit)
    }
    
    // MARK: - Stats
    var currentStreak: Int {
        guard !habit.completions.isEmpty else { return 0 }
        let sorted = habit.completions.sorted(by: >)
        var streak = 0
        var date = Calendar.current.startOfDay(for: Date())
        for completion in sorted {
            if Calendar.current.isDate(completion, inSameDayAs: date) {
                streak += 1
                date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
            } else {
                break
            }
        }
        return streak
    }
    
    var longestStreak: Int {
        guard !habit.completions.isEmpty else { return 0 }
        let sorted = habit.completions.sorted()
        var maxStreak = 1
        var currentStreak = 1
        for i in 1..<sorted.count {
            let prev = sorted[i - 1]
            let curr = sorted[i]
            if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: prev)), Calendar.current.isDate(curr, inSameDayAs: nextDay) {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        return maxStreak
    }
    
    var completionRate: Double {
        guard let first = habit.completions.min() else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: first), to: Calendar.current.startOfDay(for: Date())).day ?? 0
        guard days > 0 else { return 1 }
        return Double(habit.completions.count) / Double(days + 1)
    }
    
    func updateHabit(_ updated: Habit) {
        self.habit = updated
        onUpdate(updated)
    }
    
    func deleteHabit() {
        onDelete()
    }
} 