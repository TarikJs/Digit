import Foundation
import Supabase

enum OnboardingStep {
    case name
    case dateOfBirth
    case gender
    case habitGoal
    case habitTime
}

enum Gender: String, CaseIterable {
    case male = "He/Him"
    case female = "She/Her"
    case nonBinary = "They/Them"
    case preferNotToSay = "Prefer not to say"
}

final class OnboardingViewModel: ObservableObject {
    let onComplete: () -> Void
    let onDismiss: () -> Void
    
    @Published var currentStep: OnboardingStep = .name
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @Published var selectedGender: Gender?
    @Published var habitGoal: String = ""
    @Published var selectedHabitTime: PreferredHabitTime?
    @Published var errorMessage: String?
    
    private let minimumAge = 18
    private let maximumAge = 100
    
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
    
    var canProceedToNextStep: Bool {
        switch currentStep {
        case .name:
            return isNameValid
        case .dateOfBirth:
            return isDateOfBirthValid
        case .gender:
            return selectedGender != nil
        case .habitGoal:
            return isHabitGoalValid
        case .habitTime:
            return selectedHabitTime != nil
        }
    }
    
    var isFirstStep: Bool {
        currentStep == .name
    }

    init(onComplete: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        self.onComplete = onComplete
        self.onDismiss = onDismiss
    }
    
    func proceedToNextStep() {
        switch currentStep {
        case .name:
            currentStep = .dateOfBirth
        case .dateOfBirth:
            currentStep = .gender
        case .gender:
            currentStep = .habitGoal
        case .habitGoal:
            currentStep = .habitTime
        case .habitTime:
            Task {
                await saveProfileAndComplete()
            }
        }
    }
    
    // Update UserProfile struct to match the database schema
    private struct UserProfile: Codable {
        let id: String
        let email: String
        let first_name: String
        let last_name: String
        let date_of_birth: String
        let gender: String
        let created_at: String?
    }
    
    private struct WelcomeEmailPayload: Encodable {
        let to: String
        let firstName: String
    }
    
    private func saveProfileAndComplete() async {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let userId = session.user.id.uuidString
            let email = session.user.email
            
            // Require a valid, non-empty email
            guard let email = email, !email.isEmpty else {
                await MainActor.run {
                    self.errorMessage = "We couldn't retrieve your email. Please try signing in again."
                }
                onDismiss() // Send user back to login if email is missing
                return
            }
            
            // Validate required fields
            guard !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  let gender = selectedGender else {
                print("Error: Missing required fields")
                await MainActor.run { self.errorMessage = "Please fill in all required fields." }
                onComplete()
                return
            }
            
            // Format date consistently
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            // Create profile with current timestamp
            let profile = UserProfile(
                id: userId,
                email: email.lowercased(), // Ensure email is lowercase for consistency
                first_name: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                last_name: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                date_of_birth: dateFormatter.string(from: dateOfBirth),
                gender: gender.rawValue,
                created_at: dateFormatter.string(from: Date())
            )
            
            print("Attempting to save profile: \(profile)")
            
            do {
                let response = try await SupabaseManager.shared.client
                    .from("profiles")
                    .upsert(profile)
                    .execute()
                print("Profile save response: \(response)")
            } catch {
                print("Failed to save profile (exception): \(error)")
                await MainActor.run { self.errorMessage = "Failed to save your profile. Please try again." }
                onComplete()
                return
            }
            
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
                    print("Welcome email sent successfully")
                } catch {
                    print("Failed to send welcome email: \(error)")
                    // Continue with onComplete even if email fails
                }
            }
            
            onComplete()
        } catch {
            print("Failed to save profile (outer catch): \(error)")
            await MainActor.run { self.errorMessage = "Failed to save your profile. Please try again." }
            onComplete()
        }
    }
    
    func goBack() {
        switch currentStep {
        case .name:
            onDismiss()
        case .dateOfBirth:
            currentStep = .name
        case .gender:
            currentStep = .dateOfBirth
        case .habitGoal:
            currentStep = .gender
        case .habitTime:
            currentStep = .habitGoal
        }
    }
} 