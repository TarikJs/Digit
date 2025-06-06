import Foundation
import SwiftUI

@MainActor
final class HabitViewModel: ObservableObject {
    private let habitRepository: HabitRepositoryProtocol
    private let userId: String
    private let notificationService: NotificationServiceProtocol
    
    @Published var currentHabit: Habit?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingCreateHabit = false
    @Published var newHabitTitle = ""
    @Published var selectedTime: PreferredHabitTime = .morning
    
    // Closure to notify on successful creation (e.g., to refresh HomeViewModel)
    var onHabitCreated: (() -> Void)?
    
    init(habitRepository: HabitRepositoryProtocol, userId: String, notificationService: NotificationServiceProtocol = NotificationService()) {
        self.habitRepository = habitRepository
        self.userId = userId
        self.notificationService = notificationService
    }
    
    func loadCurrentHabit() async {
        isLoading = true
        errorMessage = nil
        do {
            let habits = try await habitRepository.fetchHabits()
            guard let userUUID = UUID(uuidString: userId) else {
                errorMessage = "Invalid user ID format."
                isLoading = false
                return
            }
            currentHabit = habits.first { $0.userId == userUUID }
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
        unit: String?,
        tag: String?
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
                unit: unit,
                tag: tag
            )
            try await habitRepository.addHabit(habit)
            
            // Schedule notification if reminder time is set
            if reminderTime != nil {
                await notificationService.scheduleHabitReminder(for: habit)
            }
            
            onHabitCreated?()
        } catch {
            errorMessage = "Failed to create habit: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func deleteCurrentHabit() async {
        guard let habit = currentHabit else { return }
        do {
            try await habitRepository.deleteHabit(habit)
            currentHabit = nil
        } catch {
            errorMessage = "Failed to delete habit: \(error.localizedDescription)"
        }
    }
} 