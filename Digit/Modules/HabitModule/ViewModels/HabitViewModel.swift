import Foundation
import SwiftUI

@MainActor
final class HabitViewModel: ObservableObject {
    private let habitService: HabitServiceProtocol
    private let userId: String
    
    @Published var currentHabit: Habit?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingCreateHabit = false
    @Published var newHabitTitle = ""
    @Published var selectedTime: PreferredHabitTime = .morning
    
    init(habitService: HabitServiceProtocol = HabitService(), userId: String) {
        self.habitService = habitService
        self.userId = userId
    }
    
    func loadCurrentHabit() async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentHabit = try await habitService.getCurrentHabit(for: userId)
        } catch {
            errorMessage = "Failed to load habit: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func createNewHabit() async {
        guard !newHabitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a habit title"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let habit = Habit(
            userId: userId,
            title: newHabitTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            preferredTime: selectedTime
        )
        
        do {
            try await habitService.createHabit(habit)
            currentHabit = habit
            showingCreateHabit = false
            newHabitTitle = ""
        } catch {
            errorMessage = "Failed to create habit: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func toggleHabitCompletion() async {
        guard var habit = currentHabit else { return }
        
        isLoading = true
        errorMessage = nil
        
        if habit.isCompletedToday {
            habit.markIncomplete()
        } else {
            habit.markCompleted()
        }
        
        do {
            try await habitService.updateHabit(habit)
            currentHabit = habit
        } catch {
            errorMessage = "Failed to update habit: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteCurrentHabit() async {
        guard let habitId = currentHabit?.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await habitService.deleteHabit(habitId)
            currentHabit = nil
        } catch {
            errorMessage = "Failed to delete habit: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
} 