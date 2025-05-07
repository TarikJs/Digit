//
//  Constants.swift
//  Digit
//
//  Centralized constants for the Habit Builder App.
//

import Foundation
import SwiftUI

enum Constants {
    // MARK: - UI
    static let defaultHabitColor: Color = .accentColor
    static let dashboardPadding: CGFloat = 16
    static let onboardingSpacing: CGFloat = 24
    
    // MARK: - Strings
    static let appName = "Habit Builder"
    static let onboardingTitle = NSLocalizedString("onboarding_title", comment: "Onboarding title")
    static let onboardingDescription = NSLocalizedString("onboarding_description", comment: "Onboarding description")
    static let dashboardTitle = NSLocalizedString("dashboard_title", comment: "Dashboard title")
    
    // MARK: - Persistence
    static let habitsEntityName = "Habit"
    static let completionEntityName = "HabitCompletion"
    
    // MARK: - Notifications
    static let notificationCategoryIdentifier = "HABIT_REMINDER_CATEGORY"
    static let notificationActionMarkDone = "MARK_DONE_ACTION"
} 