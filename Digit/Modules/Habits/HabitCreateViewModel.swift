//
//  HabitCreateViewModel.swift
//  Digit
//
//  ViewModel for creating a new habit.
//

import Foundation
import SwiftUI

final class HabitCreateViewModel: ObservableObject {
    // MARK: - Enums
    enum HabitMode: String, CaseIterable, Identifiable {
        case build, quit
        var id: String { rawValue }
    }
    
    enum HabitCategory: String, CaseIterable, Identifiable {
        case body, mind
        var id: String { rawValue }
    }
    
    enum RepeatType: String, CaseIterable, Identifiable {
        case never, daily, weekly, custom
        var id: String { rawValue }
    }
    
    struct AlertTime: Identifiable, Equatable, Hashable {
        let id = UUID()
        let minutesBefore: Int
        var description: String {
            switch minutesBefore {
            case 0: return NSLocalizedString("at_time", comment: "At time")
            case 5: return NSLocalizedString("5_min_before", comment: "5 min before")
            case 10: return NSLocalizedString("10_min_before", comment: "10 min before")
            case 30: return NSLocalizedString("30_min_before", comment: "30 min before")
            case 60: return NSLocalizedString("1_hr_before", comment: "1 hr before")
            default: return String(format: NSLocalizedString("%d_min_before", comment: "%d min before"), minutesBefore)
            }
        }
    }
    
    // MARK: - Published Properties
    @Published var mode: HabitMode
    @Published var name: String
    @Published var description: String
    @Published var category: HabitCategory
    @Published var color: Color
    @Published var iconName: String
    @Published var hasGoal: Bool
    @Published var goalText: String
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var repeatType: RepeatType
    @Published var repeatEvery: Int
    @Published var frequency: CoreHabit.Frequency
    @Published var customDays: [Int]
    @Published var reminderTime: DateComponents?
    @Published var alertTime: AlertTime
    @Published var iconSearchText: String
    
    // MARK: - Init
    init(
        mode: HabitMode = .build,
        name: String = "",
        description: String = "",
        category: HabitCategory = .body,
        color: Color = .accentColor,
        iconName: String = "star.fill",
        hasGoal: Bool = false,
        goalText: String = "",
        startDate: Date = Date(),
        endDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
        repeatType: RepeatType = .weekly,
        repeatEvery: Int = 1,
        frequency: CoreHabit.Frequency = .daily,
        customDays: [Int] = [],
        reminderTime: DateComponents? = nil,
        alertTime: AlertTime = AlertTime(minutesBefore: 30),
        iconSearchText: String = ""
    ) {
        self.mode = mode
        self.name = name
        self.description = description
        self.category = category
        self.color = color
        self.iconName = iconName
        self.hasGoal = hasGoal
        self.goalText = goalText
        self.startDate = startDate
        self.endDate = endDate
        self.repeatType = repeatType
        self.repeatEvery = repeatEvery
        self.frequency = frequency
        self.customDays = customDays
        self.reminderTime = reminderTime
        self.alertTime = alertTime
        self.iconSearchText = iconSearchText
    }
    
    // MARK: - Validation
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (hasGoal ? !goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty : true) &&
        startDate <= endDate
    }
    
    // MARK: - Habit Creation
    func makeHabit() -> CoreHabit? {
        guard isValid else { return nil }
        return CoreHabit(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            color: color,
            iconName: iconName,
            frequency: frequency,
            customDays: frequency == .custom ? customDays : nil,
            reminderTime: reminderTime
            // Add new fields to CoreHabit as needed
        )
    }
} 