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
    
    // Closure to notify on successful creation (e.g., to refresh HomeViewModel)
    var onHabitCreated: (() -> Void)?
    
    init(habitService: HabitServiceProtocol, userId: String) {
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
    
    /// Creates a new habit and notifies on success.
    func createNewHabit(
        name: String,
        dailyGoal: Int,
        icon: String,
        startDate: Date,
        endDate: Date?,
        repeatFrequency: String,
        weekdays: [Int]?,
        reminderTime: String?,
        unit: String?
    ) async {
        isLoading = true
        errorMessage = nil
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let userId = session.user.id
            let habit = Habit(
                id: UUID(),
                userId: userId,
                name: name,
                dailyGoal: dailyGoal,
                icon: icon,
                startDate: startDate,
                endDate: endDate,
                repeatFrequency: repeatFrequency,
                weekdays: weekdays,
                reminderTime: reminderTime,
                createdAt: Date(),
                updatedAt: Date(),
                unit: unit
            )
            try await habitService.addHabit(habit)
            onHabitCreated?()
        } catch {
            errorMessage = "Failed to create habit: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func deleteCurrentHabit() async {
        guard let habitId = currentHabit?.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await habitService.deleteHabit(id: habitId)
            currentHabit = nil
        } catch {
            errorMessage = "Failed to delete habit: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
} 