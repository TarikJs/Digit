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
    @Published var availableUnits: [String] = []
    @Published var selectedUnit: String? = nil
    @Published var tag: String? = nil
    
    // MARK: - Save Callback
    var onSave: ((Bool) -> Void)?
    
    private let measurementTypeService: MeasurementTypeServiceProtocol
    private let habitRepository: HabitRepositoryProtocol
    
    init(measurementTypeService: MeasurementTypeServiceProtocol = MeasurementTypeService(), habitRepository: HabitRepositoryProtocol = HabitRepository()) {
        self.measurementTypeService = measurementTypeService
        self.habitRepository = habitRepository
    }
    
    // Fetch units when name changes
    func onNameChanged() async {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        // print("[DEBUG] onNameChanged called with name: '\(name)', trimmed: '\(trimmed)'")
        
        guard !trimmed.isEmpty else {
            // print("[DEBUG] Name is empty, clearing units")
            await MainActor.run {
                self.availableUnits = []
                self.selectedUnit = nil
            }
            return
        }
        
        do {
            // print("[DEBUG] Fetching measurement types for '\(trimmed)'")
            let types = try await measurementTypeService.fetchMeasurementTypes(for: trimmed, region: "us")
            // print("[DEBUG] Received measurement types:", types.map { "habit: '\($0.habit)', unit: '\($0.unit)'" })
            
            let units = Array(Set(types.map { $0.unit })).sorted()
            // print("[DEBUG] Available units:", units)
            // print("[DEBUG] Current selectedUnit:", selectedUnit ?? "nil")
            
            await MainActor.run {
                self.availableUnits = units
                // Always use the unit from the highest scoring (first) measurement type
                if let bestUnit = types.first?.unit {
                    self.selectedUnit = bestUnit
                    // print("[DEBUG] Updated selectedUnit to best match: '\(bestUnit)'")
                } else {
                    self.selectedUnit = units.first
                    // print("[DEBUG] No best match found, using first unit: '\(self.selectedUnit ?? "nil")'")
                }
            }
        } catch {
            // print("[DEBUG] Error fetching units:", error)
            await MainActor.run {
                self.availableUnits = []
                self.selectedUnit = nil
            }
        }
    }
    
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
            dailyGoal: goalPerDay,
            icon: selectedIcon?.systemName ?? "",
            startDate: startDate,
            endDate: endDate,
            repeatFrequency: repeatFrequency.rawValue,
            weekdays: repeatFrequency == .custom ? Array(selectedWeekdays) : nil,
            reminderTime: alertEnabled ? formattedTime(alertTime) : nil,
            unit: selectedUnit,
            tag: tag
        )
        if habitViewModel.errorMessage == nil {
            onSave?(true)
        } else {
            errorMessage = habitViewModel.errorMessage
            onSave?(false)
        }
    }
    
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
} 