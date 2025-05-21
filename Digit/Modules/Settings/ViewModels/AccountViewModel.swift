import Foundation
import Combine

// MARK: - Protocols
protocol ProfileServiceProtocol {
    func fetchProfile() async throws -> UserProfile
    func updateProfile(_ profile: UserProfile) async throws
}

protocol AuthServiceProtocol {
    func signOut() async throws
}

// MARK: - AccountViewModel
@MainActor
final class AccountViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var profile: UserProfile?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published var isSignedOut: Bool = false

    // MARK: - Dependencies
    private let profileService: ProfileServiceProtocol
    private let authService: AuthServiceProtocol

    // MARK: - Init
    init(profileService: ProfileServiceProtocol, authService: AuthServiceProtocol) {
        self.profileService = profileService
        self.authService = authService
    }

    // MARK: - Public Methods
    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedProfile = try await profileService.fetchProfile()
            profile = fetchedProfile
        } catch {
            errorMessage = NSLocalizedString("account_profile_fetch_error", comment: "Failed to load profile")
        }
        isLoading = false
    }

    func updateProfile(firstName: String, lastName: String) async {
        guard var currentProfile = profile else { return }
        isLoading = true
        errorMessage = nil
        currentProfile = UserProfile(
            id: currentProfile.id,
            email: currentProfile.email,
            first_name: firstName,
            last_name: lastName,
            user_name: currentProfile.user_name,
            date_of_birth: currentProfile.date_of_birth,
            gender: currentProfile.gender,
            created_at: currentProfile.created_at,
            region: currentProfile.region,
            setup_comp: currentProfile.setup_comp
        )
        do {
            try await profileService.updateProfile(currentProfile)
            profile = currentProfile
        } catch {
            errorMessage = NSLocalizedString("account_profile_update_error", comment: "Failed to update profile")
        }
        isLoading = false
    }

    func signOut() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signOut()
            isSignedOut = true
        } catch {
            errorMessage = NSLocalizedString("account_signout_error", comment: "Failed to sign out")
        }
        isLoading = false
    }

    // MARK: - Computed Properties
    var profileDisplayName: String {
        guard let profile = profile else { return "Guest" }
        if let userName = profile.user_name, !userName.isEmpty {
            return userName
        }
        let lastInitial = profile.last_name.first.map { String($0) } ?? ""
        let name = "\(profile.first_name) \(lastInitial)."
        return name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Guest" : name
    }

    var emailStatus: (text: String, isVerified: Bool) {
        guard let email = profile?.email, !email.isEmpty else {
            return (NSLocalizedString("Not Verified", comment: "Not verified yet"), false)
        }
        // TODO: Wire up real email verification logic here
        return (NSLocalizedString("Verified", comment: "Verified"), true)
    }
} 