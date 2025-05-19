import SwiftUI
import Foundation

struct LegalDocumentView: View {
    let title: String
    let fileName: String
    @Environment(\.dismiss) private var dismiss
    @State private var documentText: String = ""
    @State private var attributedText: AttributedString? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let attributedText {
                        Text(attributedText)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 8)
                    } else {
                        Text(documentText)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 8)
                    }
                }
                .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                switch fileName {
                case "PrivacyPolicy":
                    documentText = LegalDocuments.privacyPolicy
                case "TermsOfService":
                    documentText = LegalDocuments.termsOfService
                case "Licenses":
                    documentText = LegalDocuments.licenses
                default:
                    documentText = "Document not found."
                }
                if let attributed = try? AttributedString(markdown: documentText) {
                    attributedText = attributed
                }
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var authCoordinator: AuthCoordinator
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @State private var pushNotificationsEnabled = true
    @State private var legalSheet: LegalSheetType?
    @State private var isEditingProfile = false
    @State private var isBillingPresented = false

    enum LegalSheetType: Identifiable {
        case privacy, terms, licenses
        var id: Self { self }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Account Section
                SettingsSection(title: "Account") {
                    VStack(spacing: 0) {
                        Button(action: { isEditingProfile = true }) {
                            AccountProfileCard(
                                userName: accountViewModel.profile?.user_name ?? "Guest"
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 0)
                        Divider().background(Color.digitDivider)
                        SectionContentWithDividers(rows: [
                            AnyView(SettingsRow(
                                icon: "envelope",
                                label: "Email",
                                subtitle: nil,
                                action: {
                                    // TODO: Navigate to Change Email screen
                                    print("Change Email tapped")
                                },
                                trailing: AnyView(
                                    Text(accountViewModel.emailStatus.text)
                                        .foregroundColor(accountViewModel.emailStatus.isVerified ? .green : .red)
                                        .font(.subheadline)
                                )
                            )),
                            AnyView(SettingsRow(
                                icon: "creditcard",
                                label: "Billing",
                                subtitle: nil,
                                action: {
                                    isBillingPresented = true
                                }
                            )),
                            AnyView(SettingsRow(icon: "rectangle.portrait.and.arrow.right", label: "Sign Out", subtitle: nil, isDestructive: true) {
                                authCoordinator.currentState = .auth
                            })
                        ])
                    }
                }
                // Notifications Section
                SettingsSection(title: "Notifications", horizontalPadding: 8) {
                    SectionContentWithDividers(rows: [
                        AnyView(Toggle(isOn: $pushNotificationsEnabled) {
                            Label("Push Notifications", systemImage: "bell")
                        }
                        .tint(Color.digitBrand))
                    ])
                }
                // App Section
                SettingsSection(title: "App") {
                    SectionContentWithDividers(rows: [
                        AnyView(SettingsRow(icon: "info.circle", label: "About", subtitle: nil) {
                            // TODO: Show About modal
                            print("About tapped")
                        }),
                        AnyView(SettingsRow(icon: "star", label: "Rate App", subtitle: nil) {
                            // TODO: Open App Store rating
                            print("Rate App tapped")
                        }),
                        AnyView(SettingsRow(icon: "envelope.open", label: "Send Feedback", subtitle: nil) {
                            // TODO: Open feedback form
                            print("Send Feedback tapped")
                        })
                    ])
                }
                // Legal Section
                SettingsSection(title: "Legal") {
                    SectionContentWithDividers(rows: [
                        AnyView(SettingsRow(icon: "hand.raised", label: "Privacy Policy", subtitle: nil) {
                            legalSheet = .privacy
                        }),
                        AnyView(SettingsRow(icon: "doc.text", label: "Terms of Service", subtitle: nil) {
                            legalSheet = .terms
                        }),
                        AnyView(SettingsRow(icon: "doc.plaintext", label: "Licenses", subtitle: nil) {
                            legalSheet = .licenses
                        })
                    ])
                }
                Spacer(minLength: 32)
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
        }
        .background(Color.digitGrayLight.ignoresSafeArea())
        .sheet(isPresented: $isEditingProfile) {
            ProfileEditView()
                .environmentObject(accountViewModel)
        }
        .sheet(item: $legalSheet) { sheet in
            switch sheet {
            case .privacy:
                LegalDocumentView(title: "Privacy Policy", fileName: "PrivacyPolicy")
            case .terms:
                LegalDocumentView(title: "Terms of Service", fileName: "TermsOfService")
            case .licenses:
                LegalDocumentView(title: "Licenses", fileName: "Licenses")
            }
        }
        .sheet(isPresented: $isBillingPresented) {
            BillingView(isPresented: $isBillingPresented)
        }
    }
}

// MARK: - Section Header and Row Components

struct SectionContentWithDividers: View {
    let rows: [AnyView]
    var body: some View {
        ForEach(0..<rows.count, id: \.self) { idx in
            rows[idx]
            if idx < rows.count - 1 {
                Divider().background(Color.digitDivider)
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    var horizontalPadding: CGFloat

    init(title: String, horizontalPadding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.title = title
        self.horizontalPadding = horizontalPadding
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color.digitBrand)
                .padding(.top, 16)
                .padding(.leading, 4)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(Text(title))
            VStack(spacing: 0) {
                let contentViews = Mirror(reflecting: content).children.compactMap { $0.value as? AnyView }
                if contentViews.isEmpty {
                    content
                } else {
                    SectionContentWithDividers(rows: contentViews)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.digitBrand, lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 0)
    }
}

struct SettingsRow: View {
    let icon: String
    let label: String
    let subtitle: String?
    var isDestructive: Bool = false
    var action: (() -> Void)? = nil
    var trailing: AnyView? = nil

    var body: some View {
        Button(action: { action?() }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .red : .digitBrand)
                VStack(alignment: .leading) {
                    Text(label)
                        .foregroundColor(isDestructive ? .red : .primary)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if let trailing = trailing {
                    trailing
                } else if action == nil {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(isDestructive ? "\(label), Destructive" : label))
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Account Profile Card
struct AccountProfileCard: View {
    let userName: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .background(
                    Circle()
                        .fill(Color.white)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(userName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.digitBrand)
                Text("Account Settings & Info.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 0)
    }
}

// MARK: - Profile Edit View (Full UI)
struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var accountViewModel: AccountViewModel

    @State private var firstName: String = ""
    @State private var lastName: String = ""

    private var displayName: String {
        guard let profile = accountViewModel.profile else { return "Guest" }
        let lastInitial = profile.last_name.first.map { String($0) } ?? ""
        return "\(profile.first_name) \(lastInitial)."
    }

    private var userName: String? {
        accountViewModel.profile?.user_name
    }

    private var isGuest: Bool {
        accountViewModel.profile == nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Top bar
                HStack {
                    Button(action: { /* Sign out action */ }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                            .font(.system(size: 17, weight: .semibold))
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .foregroundColor(.blue)
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                .padding([.horizontal, .top], 20)
                .padding(.bottom, 8)

                // Avatar, username, and claim username in a card
                VStack(spacing: 8) {
                    ZStack(alignment: .bottomTrailing) {
                        Image("AppLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 88, height: 88)
                            .clipShape(Circle())
                            .background(
                                Circle().fill(Color.white)
                            )
                        Button(action: { /* Change avatar */ }) {
                            Image(systemName: "camera.fill")
                                .foregroundColor(Color.digitProgressGreen3)
                                .padding(6)
                                .background(Circle().fill(Color.white))
                                .shadow(radius: 1)
                        }
                        .offset(x: 6, y: 6)
                    }
                    .frame(height: 100)
                    Text(displayName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.digitBrand)
                    if let userName = userName, !userName.isEmpty {
                        Text("@\(userName)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.digitProgressGreen3)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(16)
                    } else {
                        Button(action: { /* Claim username */ }) {
                            Text("@ Claim Username")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.digitProgressGreen3)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(16)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.digitBrand, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Name section title and card
                Text("NAME")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.digitBrand)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                VStack(spacing: 0) {
                    TextField("First Name", text: $firstName)
                        .disabled(isGuest)
                        .padding(12)
                        .foregroundColor(Color.digitBrand)
                    Divider().background(Color.digitDivider)
                    TextField("Last Name", text: $lastName)
                        .disabled(isGuest)
                        .padding(12)
                        .foregroundColor(Color.digitBrand)
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.digitBrand, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)
                .onAppear {
                    if let profile = accountViewModel.profile {
                        firstName = profile.first_name
                        lastName = profile.last_name
                    }
                }

                // Account Status section title and card
                Text("ACCOUNT STATUS")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.digitBrand)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color.digitBrand)
                        Text("Free Member")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color.digitBrand)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.digitBrand, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)

                // Sign-In Methods section title and card
                Text("SIGN-IN METHOD")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.digitBrand)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "applelogo")
                            .foregroundColor(Color.digitBrand)
                        Text("Apple ID")
                            .font(.system(size: 17))
                        Spacer()
                        if accountViewModel.profile != nil {
                            Text("Linked")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.digitProgressGreen3)
                        }
                    }
                    .padding(.vertical, 12)
                    Divider().background(Color.digitDivider)
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .foregroundColor(Color.digitBrand)
                        Text("Google Account")
                            .font(.system(size: 17))
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    Divider().background(Color.digitDivider)
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(Color.digitBrand)
                        Text("Email Address")
                            .font(.system(size: 17))
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.digitBrand, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)

                // Email section title and card
                Text("EMAIL")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.digitBrand)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(Color.digitBrand)
                        Text("user@email.com") // Replace with actual user email
                            .font(.system(size: 17))
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.digitBrand, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)

                // Danger Zone section title and card
                Text("DANGER ZONE")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.digitBrand)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                VStack(spacing: 0) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Delete Account")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                            Text("This will permanently delete your account and all data tied to it.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Button(action: { /* Delete account action */ }) {
                            Text("Delete")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 12)
                    Divider().background(Color.digitDivider)
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Delete All Habit Data")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                            Text("This will delete all habit data for your account and may affect your rewards and streaks.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Button(action: { /* Delete all habit data action */ }) {
                            Text("Delete")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.digitBrand, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(Color.digitGrayLight)
        }
        .ignoresSafeArea()
    }
}

// Minimal working implementations for preview/testing
class DummyProfileService: ProfileServiceProtocol {
    func fetchProfile() async throws -> UserProfile {
        return UserProfile(
            id: "dummy-id",
            email: "dummy@email.com",
            first_name: "Jane",
            last_name: "Doe",
            user_name: nil,
            date_of_birth: "1990-01-01",
            gender: "female",
            created_at: nil
        )
    }
}

class DummyAuthService: AuthServiceProtocol {
    func signOut() async throws {}
}

#if DEBUG
#Preview {
    let mockAuthViewModel = AuthViewModel()
    SettingsView()
        .environmentObject(AuthCoordinator(authViewModel: mockAuthViewModel))
        .environmentObject(mockAuthViewModel)
}
#endif

// MARK: - Billing View
struct BillingView: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Section title
                    Text("BILLING")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.digitBrand)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                    // Active Plan card
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "creditcard")
                                .foregroundColor(Color.digitBrand)
                            Text("Active Plan")
                                .font(.system(size: 17, weight: .semibold))
                            Spacer()
                            Text("Free Plan") // Placeholder
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.digitBrand, lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 16)
                    // Restore Purchases & Enter Code card
                    VStack(spacing: 0) {
                        Button(action: { /* Restore Purchases action */ }) {
                            HStack {
                                Image(systemName: "arrow.clockwise.circle")
                                    .foregroundColor(Color.digitBrand)
                                Text("Restore Purchases")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color.digitProgressGreen3)
                                Spacer()
                            }
                        }
                        .padding(.vertical, 12)
                        Divider().background(Color.digitDivider)
                        Button(action: { /* Enter Code action */ }) {
                            HStack {
                                Image(systemName: "key")
                                    .foregroundColor(Color.digitBrand)
                                Text("Enter Code")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color.digitProgressGreen3)
                                Spacer()
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.digitBrand, lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 16)
                }
                .background(Color.digitGrayLight)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { isPresented = false }
                        .foregroundColor(Color.digitProgressGreen3)
                }
            }
        }
    }
} 
