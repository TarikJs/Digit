//
//  SettingsView.swift
//  Digit
//
//  SwiftUI view for app settings.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(NSLocalizedString("notifications_section_label", comment: "Notifications"))) {
                    HStack {
                        Text(NSLocalizedString("notification_permission_status_label", comment: "Notification permission status"))
                        Spacer()
                        Text(statusText)
                            .foregroundStyle(.secondary)
                    }
                    Button(action: {
                        viewModel.openSystemSettings()
                    }) {
                        Text(NSLocalizedString("open_settings_button", comment: "Open Settings"))
                    }
                }
                Section(header: Text(NSLocalizedString("app_info_section_label", comment: "App Info"))) {
                    HStack {
                        Text(NSLocalizedString("version_label", comment: "Version"))
                        Spacer()
                        Text("\(viewModel.appVersion) (\(viewModel.appBuild))")
                            .foregroundStyle(.secondary)
                    }
                    Link(NSLocalizedString("privacy_policy_label", comment: "Privacy Policy"), destination: URL(string: "https://your-privacy-policy-url.com")!)
                }
            }
            .navigationTitle(NSLocalizedString("settings_title", comment: "Settings"))
        }
    }
    
    private var statusText: String {
        switch viewModel.notificationStatus {
        case .authorized: return NSLocalizedString("permission_authorized", comment: "Authorized")
        case .denied: return NSLocalizedString("permission_denied", comment: "Denied")
        case .notDetermined: return NSLocalizedString("permission_not_determined", comment: "Not Determined")
        case .provisional: return NSLocalizedString("permission_provisional", comment: "Provisional")
        case .ephemeral: return NSLocalizedString("permission_ephemeral", comment: "Ephemeral")
        @unknown default: return "-"
        }
    }
} 