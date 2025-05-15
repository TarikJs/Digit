import Foundation
import SwiftUI

@MainActor
final class NewHabitViewModel: ObservableObject {
    // MARK: - Nested Types
    struct Icon: Identifiable, Equatable {
        let id: String
        let systemName: String
    }
    
    enum RepeatFrequency: String, CaseIterable, Identifiable {
        case daily = "Daily"
        case weekly = "Weekly"
        case custom = "Custom"
        var id: String { rawValue }
    }
    
    // MARK: - Published Properties
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var goalPerDay: Int = 1
    let minGoal: Int = 1
    let maxGoal: Int = 100
    @Published var startDate: Date = Date()
    @Published var endDate: Date? = nil
    @Published var alertEnabled: Bool = false
    @Published var alertTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false
    @Published var selectedIcon: Icon? = nil
    @Published var repeatFrequency: RepeatFrequency = .daily
    @Published var selectedWeekdays: Set<Int> = []
    @Published var errorMessage: String? = nil
    
    // MARK: - Save Callback
    var onSave: ((Bool) -> Void)?
    
    // MARK: - Computed Properties
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && goalPerDay >= minGoal && selectedIcon != nil
    }
    
    // MARK: - Save Logic
    func saveHabit(using habitViewModel: HabitViewModel) async {
        guard canSave else {
            errorMessage = "Please fill all required fields."
            onSave?(false)
            return
        }
        isSaving = true
        defer { isSaving = false }
        await habitViewModel.createNewHabit(
            name: name,
            description: description.isEmpty ? nil : description,
            dailyGoal: goalPerDay,
            icon: selectedIcon?.systemName ?? "",
            startDate: startDate,
            endDate: endDate,
            repeatFrequency: repeatFrequency.rawValue,
            weekdays: repeatFrequency == .custom ? Array(selectedWeekdays) : nil,
            reminderTime: alertEnabled ? formattedTime(alertTime) : nil
        )
        if habitViewModel.errorMessage == nil {
            onSave?(true)
        } else {
            errorMessage = habitViewModel.errorMessage
            onSave?(false)
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
} 