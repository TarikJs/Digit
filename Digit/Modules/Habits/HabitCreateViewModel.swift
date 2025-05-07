//
//  HabitCreateViewModel.swift
//  Digit
//
//  ViewModel for creating a new habit.
//

import Foundation
import SwiftUI

final class HabitCreateViewModel: ObservableObject {
    @Published var name: String
    @Published var color: Color
    @Published var iconName: String
    @Published var frequency: CoreHabit.Frequency
    @Published var customDays: [Int]
    @Published var reminderTime: DateComponents?
    
    init(name: String = "", color: Color = .accentColor, iconName: String = "star.fill", frequency: CoreHabit.Frequency = .daily, customDays: [Int] = [], reminderTime: DateComponents? = nil) {
        self.name = name
        self.color = color
        self.iconName = iconName
        self.frequency = frequency
        self.customDays = customDays
        self.reminderTime = reminderTime
    }
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func makeHabit() -> CoreHabit? {
        guard isValid else { return nil }
        return CoreHabit(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            color: color,
            iconName: iconName,
            frequency: frequency,
            customDays: frequency == .custom ? customDays : nil,
            reminderTime: reminderTime
        )
    }
} 