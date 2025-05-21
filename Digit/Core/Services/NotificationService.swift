import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func requestNotificationPermissions() async -> Bool
    func scheduleHabitReminder(for habit: Habit) async
    func cancelHabitReminders(for habitId: UUID)
}

final class NotificationService: NotificationServiceProtocol {
    private let notificationCenter = UNUserNotificationCenter.current()
    private let progressService: HabitProgressServiceProtocol
    // Keep a strong reference to the delegate
    private var notificationDelegate: NotificationDelegate?
    
    init(progressService: HabitProgressServiceProtocol = HabitProgressService()) {
        self.progressService = progressService
    }
    
    func requestNotificationPermissions() async -> Bool {
        do {
            let settings = await notificationCenter.notificationSettings()
            if settings.authorizationStatus == .notDetermined {
                return try await notificationCenter.requestAuthorization(options: [.alert, .sound])
            }
            return settings.authorizationStatus == .authorized
        } catch {
            print("[ERROR] Failed to request notification permissions: \(error)")
            return false
        }
    }
    
    func scheduleHabitReminder(for habit: Habit) async {
        guard let reminderTimeString = habit.reminderTime else { return }
        
        // Parse reminder time
        let timeComponents = reminderTimeString.split(separator: ":")
        guard timeComponents.count == 3,
              let hour = Int(timeComponents[0]),
              let minute = Int(timeComponents[1]) else {
            print("[ERROR] Invalid reminder time format: \(reminderTimeString)")
            return
        }
        
        // Cancel any existing notifications for this habit
        cancelHabitReminders(for: habit.id)
        
        // Create date components for the trigger
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // Create trigger that repeats daily
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create notification request with a dynamic content provider
        let request = UNNotificationRequest(
            identifier: "habit-\(habit.id.uuidString)",
            content: UNMutableNotificationContent(),  // Empty content, will be updated before delivery
            trigger: trigger
        )
        
        // Add the notification request
        do {
            try await notificationCenter.add(request)
            
            // Set up a time-sensitive background task to update content before delivery
            notificationDelegate = NotificationDelegate(
                habit: habit,
                progressService: progressService
            )
            notificationCenter.delegate = notificationDelegate
            
            print("[DEBUG] Successfully scheduled notification for habit: \(habit.name)")
        } catch {
            print("[ERROR] Failed to schedule notification: \(error)")
        }
    }
    
    func cancelHabitReminders(for habitId: UUID) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["habit-\(habitId.uuidString)"])
    }
}

// MARK: - Notification Delegate
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let habit: Habit
    private let progressService: HabitProgressServiceProtocol
    
    init(habit: Habit, progressService: HabitProgressServiceProtocol) {
        self.habit = habit
        self.progressService = progressService
        super.init()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Task {
            // Check if this notification is for our habit
            guard notification.request.identifier == "habit-\(habit.id.uuidString)" else {
                completionHandler([.banner, .sound])
                return
            }
            
            // Get today's progress
            let today = Date()
            if let progress = try? await progressService.fetchProgress(userId: habit.userId, habitId: habit.id, date: today) {
                // If already completed, don't show notification
                if progress.progress >= progress.goal {
                    completionHandler([])
                    return
                }
                
                // Update notification content with progress info
                let content = notification.request.content.mutableCopy() as! UNMutableNotificationContent
                content.title = "Time for \(habit.name)"
                let remaining = progress.goal - progress.progress
                content.body = "You've done \(progress.progress)/\(progress.goal)\(habit.unit != nil ? " \(habit.unit!)" : ""). \(remaining) more to go!"
                content.sound = .default
                
                // Update the notification with new content
                let request = UNNotificationRequest(
                    identifier: notification.request.identifier,
                    content: content,
                    trigger: notification.request.trigger
                )
                try? await center.add(request)
            }
            
            completionHandler([.banner, .sound])
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
} 