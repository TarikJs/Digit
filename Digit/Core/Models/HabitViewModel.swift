import Foundation
import SwiftUI

@MainActor
public class HabitViewModel: ObservableObject {
    @Published private(set) var habits: [Habit] = []
    private let habitStore: HabitStore
    
    public init(habitStore: HabitStore = HabitStore()) {
        self.habitStore = habitStore
        loadHabits()
    }
    
    private func loadHabits() {
        habits = habitStore.loadHabits()
        resetProgressIfNeeded()
    }
    
    private func saveHabits() {
        habitStore.saveHabits(habits)
    }
    
    private func resetProgressIfNeeded() {
        var needsSave = false
        habits = habits.map { habit in
            var updatedHabit = habit
            updatedHabit.resetProgressIfNeeded()
            if updatedHabit != habit {
                needsSave = true
            }
            return updatedHabit
        }
        
        if needsSave {
            saveHabits()
        }
    }
    
    // MARK: - Public Methods
    
    public func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
    }
    
    public func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }
    
    public func incrementProgress(for habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        var updatedHabit = habits[index]
        updatedHabit.incrementProgress()
        habits[index] = updatedHabit
        saveHabits()
    }
    
    public func decrementProgress(for habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        var updatedHabit = habits[index]
        updatedHabit.decrementProgress()
        habits[index] = updatedHabit
        saveHabits()
    }
    
    public func updateHabit(_ updatedHabit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == updatedHabit.id }) else { return }
        habits[index] = updatedHabit
        saveHabits()
    }
} 