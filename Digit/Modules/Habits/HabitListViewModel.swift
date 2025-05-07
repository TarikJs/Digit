//
//  HabitListViewModel.swift
//  Digit
//
//  ViewModel for the main habit dashboard.
//

import Foundation
import SwiftUI

final class HabitListViewModel: ObservableObject {
    @Published private(set) var habits: [Habit] = [] {
        didSet { store.saveHabits(habits) }
    }
    private let store: HabitStore
    
    init(store: HabitStore = HabitStore()) {
        self.store = store
        self.habits = store.loadHabits()
    }
    
    func markHabitCompleted(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        let today = Calendar.current.startOfDay(for: Date())
        if !habits[index].completions.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            habits[index].completions.append(today)
        }
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
    }
    
    func updateHabit(_ updated: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == updated.id }) else { return }
        habits[index] = updated
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
    }
} 