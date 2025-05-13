import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authCoordinator: AuthCoordinator
    @State private var pushNotificationsEnabled = true

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Account Section
                SettingsSection(title: "Account") {
                    SettingsRow(icon: "person.crop.circle", label: "Profile")
                    SettingsRow(icon: "envelope", label: "Change Email")
                    SettingsRow(icon: "rectangle.portrait.and.arrow.right", label: "Sign Out", isDestructive: true) {
                        authCoordinator.currentState = .auth
                    }
                }
                // Notifications Section
                SettingsSection(title: "Notifications") {
                    Toggle(isOn: $pushNotificationsEnabled) {
                        Label("Push Notifications", systemImage: "bell")
                    }
                    .padding(.horizontal)
                }
                // App Section
                SettingsSection(title: "App") {
                    SettingsRow(icon: "info.circle", label: "About")
                    SettingsRow(icon: "hand.raised", label: "Privacy Policy")
                    SettingsRow(icon: "doc.text", label: "Terms of Service")
                    SettingsRow(icon: "star", label: "Rate App")
                    SettingsRow(icon: "envelope.open", label: "Send Feedback")
                    SettingsRow(icon: "doc.plaintext", label: "Licenses")
                }
            }
            .padding(.top, 0)
            .padding(.horizontal, 16)
            .background(Color.digitBackground)
        }
    }
}

// MARK: - Section Header and Row Components

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let label: String
    var isDestructive: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .red : .digitBrand)
                Text(label)
                    .foregroundColor(isDestructive ? .red : .primary)
                Spacer()
                if action == nil {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    let mockAuthViewModel = AuthViewModel()
    SettingsView()
        .environmentObject(AuthCoordinator(authViewModel: mockAuthViewModel))
        .environmentObject(mockAuthViewModel)
}
#endif 