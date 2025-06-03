import Foundation
import Supabase

enum OnboardingStep {
    case name
    case userName
    case email
    case gender
    case dateOfBirth
    case region
    case enableNotification
}

enum Gender: String, CaseIterable {
    case male = "He/Him"
    case female = "She/Her"
    case nonBinary = "They/Them"
    case preferNotToSay = "Prefer not to say"
}

final class OnboardingViewModel: ObservableObject {
    let onComplete: () -> Void
    var onDismiss: () -> Void
    
    @Published var currentStep: OnboardingStep = .name
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @Published var selectedGender: Gender?
    @Published var habitGoal: String = ""
    @Published var notificationsEnabled: Bool = false {
        didSet {
            if notificationsEnabled {
                Task {
                    let notificationService = NotificationService(progressService: HabitProgressService())
                    let granted = await notificationService.requestNotificationPermissions()
                    if !granted {
                        await MainActor.run {
                            notificationsEnabled = false
                        }
                    }
                }
            }
        }
    }
    @Published var errorMessage: String?
    @Published var userName: String = ""
    @Published var isCheckingUserName = false
    @Published var selectedRegion: String? = nil
    @Published var isEmailVerified: Bool
    let isSocialSignIn: Bool
    
    private let minimumAge = 18
    private let maximumAge = 100
    
    private let userProfileRepository: UserProfileRepositoryProtocol
    
    var isNameValid: Bool {
        isFirstNameValid && isLastNameValid
    }
    
    private var isFirstNameValid: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }
    
    private var isLastNameValid: Bool {
        lastName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }
    
    var isDateOfBirthValid: Bool {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        guard let age = ageComponents.year else { return false }
        return age >= minimumAge && age <= maximumAge
    }
    
    var isHabitGoalValid: Bool {
        habitGoal.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }
    
    var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let maxDate = calendar.date(byAdding: .year, value: -minimumAge, to: Date()) ?? Date()
        let minDate = calendar.date(byAdding: .year, value: -maximumAge, to: Date()) ?? Date()
        return minDate...maxDate
    }
    
    var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".") && trimmed.count >= 5
    }
    
    var isUserNameValid: Bool {
        let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 3 && trimmed.range(of: "^[A-Za-z0-9_]+$", options: .regularExpression) != nil
    }
    
    var canProceedToNextStep: Bool {
        switch currentStep {
        case .name:
            return isNameValid
        case .userName:
            return !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && userName.count >= 3
        case .email:
            return !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isValidEmail(email)
        case .gender:
            return selectedGender != nil
        case .dateOfBirth:
            let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
            return age >= minimumAge && age <= maximumAge
        case .region:
            return selectedRegion != nil
        case .enableNotification:
            return true
        }
    }
    
    var isFirstStep: Bool {
        currentStep == .name
    }
    
    // Reference to AuthViewModel for verification and resend
    weak var authViewModel: AuthViewModel?
    
    func refreshEmailVerificationStatus() async {
        guard let authViewModel else { return }
        // Only refresh session if a session exists
        var verified = false
        do {
            let _ = try await SupabaseManager.shared.client.auth.session
            do {
                try await SupabaseManager.shared.client.auth.refreshSession()
            } catch {
                print("Failed to refresh session: \(error)")
            }
            verified = await authViewModel.isEmailVerified()
        } catch {
            print("No valid session, cannot refresh: \(error)")
            // Optionally, handle logout or prompt user to log in again
        }
        let isVerified = verified
        await MainActor.run { self.isEmailVerified = isVerified }
    }
    
    func resendVerificationEmail() async {
        await authViewModel?.resendVerificationEmail()
    }
    
    init(email: String = "", isEmailVerified: Bool = false, isSocialSignIn: Bool = false, authViewModel: AuthViewModel? = nil, userProfileRepository: UserProfileRepositoryProtocol = UserProfileRepository(), onComplete: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        self.email = email
        self.isEmailVerified = isEmailVerified
        self.isSocialSignIn = isSocialSignIn
        self.authViewModel = authViewModel
        self.userProfileRepository = userProfileRepository
        self.onComplete = onComplete
        self.onDismiss = onDismiss
    }
    
    func proceedToNextStep() {
        switch currentStep {
        case .name:
            currentStep = .userName
        case .userName:
            Task {
                await checkBlockedUserNameAndProceed()
            }
        case .email:
            currentStep = .gender
        case .gender:
            currentStep = .dateOfBirth
        case .dateOfBirth:
            currentStep = .region
        case .region:
            currentStep = .enableNotification
        case .enableNotification:
            Task {
                await saveProfileAndComplete()
            }
        }
    }
    
    private struct WelcomeEmailPayload: Encodable {
        let to: String
        let firstName: String
    }
    
    private func saveProfileAndComplete() async {
        do {
            // Check for valid Supabase Auth session and user
            guard let session = try? await SupabaseManager.shared.client.auth.session,
                  !session.user.id.uuidString.isEmpty else {
                await MainActor.run {
                    self.errorMessage = "Authentication failed. Please try signing in again."
                    print("[DEBUG] Early return: No valid session")
                }
                return
            }
            let userId = session.user.id.uuidString
            // Use the email provided by the user during onboarding
            let email = self.email.trimmingCharacters(in: .whitespacesAndNewlines)
            // Require a valid, non-empty email from onboarding
            guard !email.isEmpty else {
                await MainActor.run {
                    self.errorMessage = "Please enter a valid email address to continue."
                    print("[DEBUG] Early return: Email is empty")
                }
                return
            }
            // Relaxed: Allow empty names for debugging Apple Sign-In
            if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                selectedGender == nil {
                print("[DEBUG] Warning: Missing required fields (firstName, lastName, or gender)")
            }
            let genderString = selectedGender?.rawValue ?? ""
            // Format date consistently
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            // Create profile with current timestamp
            let profile = UserProfile(
                id: userId,
                email: email.lowercased(),
                firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                userName: userName.trimmingCharacters(in: .whitespacesAndNewlines),
                dateOfBirth: dateOfBirth,
                gender: genderString,
                createdAt: Date(),
                region: selectedRegion,
                setupComp: "Y"
            )
            print("[DEBUG] Attempting to save profile: \(profile)")
            try await userProfileRepository.saveProfile(profile)
            // Send welcome email
            Task {
                do {
                    let emailPayload = WelcomeEmailPayload(
                        to: email,
                        firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                    try await SupabaseManager.shared.client.functions.invoke(
                        "send-email",
                        options: .init(body: emailPayload)
                    )
                    print("[DEBUG] Welcome email sent successfully")
                }
            }
            onComplete()
        } catch {
            print("[DEBUG] Failed to save profile (outer catch): \(error)")
            await MainActor.run { self.errorMessage = "Failed to save your profile. Please try again." }
            onComplete()
        }
    }
    
    func goBack() {
        switch currentStep {
        case .name:
            onDismiss()
        case .userName:
            currentStep = .name
        case .email:
            currentStep = .userName
        case .gender:
            currentStep = isEmailVerified ? .userName : .email
        case .dateOfBirth:
            currentStep = .gender
        case .region:
            currentStep = .dateOfBirth
        case .enableNotification:
            currentStep = .region
        }
    }
    
    private struct BlockedUserName: Decodable {
        let user_name: String
    }

    private func checkBlockedUserNameAndProceed() async {
        await MainActor.run {
        isCheckingUserName = true
        errorMessage = nil
        }
        do {
            let response = try await SupabaseManager.shared.client
                .from("blocked_usernames")
                .select()
                .eq("user_name", value: userName.lowercased())
                .execute()
            let blockedUsernames = try JSONDecoder().decode([BlockedUserName].self, from: response.data)
            await MainActor.run {
                isCheckingUserName = false
                if blockedUsernames.isEmpty {
                    currentStep = isEmailVerified ? .gender : .email
                } else {
                    errorMessage = "This username is not available. Please try another."
                }
            }
        } catch {
            print("Error checking username: \(error)")
            await MainActor.run {
                isCheckingUserName = false
                errorMessage = "Failed to verify username. Please try again."
            }
        }
    }
    
    func markProfileInWork() async {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let userId = session.user.id.uuidString
            let partialProfile = UserProfile(
                id: userId,
                email: email,
                firstName: firstName,
                lastName: lastName,
                userName: userName,
                dateOfBirth: nil,
                gender: "",
                createdAt: nil,
                region: nil,
                setupComp: "IW"
            )
            _ = try await SupabaseManager.shared.client
                .from("profiles")
                .upsert(partialProfile)
                .execute()
        } catch {
            print("[DEBUG] Failed to mark profile in work: \(error)")
        }
    }
    
    func deletePartialProfileIfAbandoned() async {
        await authViewModel?.deleteCurrentUserProfileIfNotComplete()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
} 