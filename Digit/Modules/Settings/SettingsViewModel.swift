//
//  SettingsViewModel.swift
//  Digit
//
//  ViewModel for the app settings screen.
//

import Foundation
import UserNotifications
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    init() {
        fetchNotificationStatus()
    }
    
    func fetchNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationStatus = settings.authorizationStatus
            }
        }
    }
    
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
} 