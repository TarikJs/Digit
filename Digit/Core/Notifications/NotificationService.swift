//
//  NotificationService.swift
//  Digit
//
//  Handles local notification permissions and scheduling for habit reminders.
//

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleReminder(for habit: Habit) {
        guard let reminderTime = habit.reminderTime else { return }
        let content = UNMutableNotificationContent()
        content.title = String(format: NSLocalizedString("reminder_title_format", comment: "Reminder title"), habit.name)
        content.body = NSLocalizedString("reminder_body", comment: "Reminder body")
        content.sound = .default
        content.categoryIdentifier = Constants.notificationCategoryIdentifier
        let trigger = UNCalendarNotificationTrigger(dateMatching: reminderTime, repeats: true)
        let request = UNNotificationRequest(identifier: notificationID(for: habit), content: content, trigger: trigger)
        center.add(request)
    }
    
    func cancelReminder(for habit: Habit) {
        center.removePendingNotificationRequests(withIdentifiers: [notificationID(for: habit)])
    }
    
    private func notificationID(for habit: Habit) -> String {
        "habit_reminder_\(habit.id.uuidString)"
    }
} 