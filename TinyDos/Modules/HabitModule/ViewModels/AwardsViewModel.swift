import SwiftUI

final class AwardsViewModel: ObservableObject {
    // MARK: - Dependencies
    private let awardRepository: AwardRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol
    
    // MARK: - Published Properties
    @Published var userName: String = "Jane Appleseed"
    @Published var email: String = "jane@digitapp.com"
    @Published var stats: [ProfileStat] = [
        .init(icon: "flame.fill", title: "Streak", value: "21 days", color: .digitHabitGreen),
        .init(icon: "star.fill", title: "Awards", value: "5 badges", color: .digitHabitPurple),
        .init(icon: "heart.fill", title: "Matches", value: "12", color: .digitBrand)
    ]
    @Published var awards: [Award] = []
    @Published var challenges: [Challenge] = []
    
    // MARK: - Initialization
    init(awardRepository: AwardRepositoryProtocol = AwardRepository(), userProfileRepository: UserProfileRepositoryProtocol = UserProfileRepository()) {
        self.awardRepository = awardRepository
        self.userProfileRepository = userProfileRepository
        Task { await loadData() }
    }
    
    // MARK: - Data Loading
    private func loadData() async {
        await loadProfileFromCache()
        await loadAwardsFromCache()
        // Background sync
        Task.detached { [weak self] in
            await self?.syncProfile()
            await self?.syncAwards()
        }
    }
    
    private func loadProfileFromCache() async {
        if let profile = try? await userProfileRepository.fetchProfile() {
            await MainActor.run {
                self.userName = profile.userName ?? "Jane Appleseed"
                self.email = profile.email ?? "jane@digitapp.com"
            }
        }
    }
    
    private func loadAwardsFromCache() async {
        if let cachedAwards = try? await awardRepository.fetchAwards() {
            await MainActor.run {
                self.awards = cachedAwards
            }
        }
    }
    
    private func syncProfile() async {
        // This should trigger a remote fetch and update the cache
        if let profile = try? await userProfileRepository.fetchProfile() {
            await MainActor.run {
                self.userName = profile.userName ?? "Jane Appleseed"
                self.email = profile.email ?? "jane@digitapp.com"
            }
        }
    }
    
    private func syncAwards() async {
        // This should trigger a remote fetch and update the cache
        if let remoteAwards = try? await awardRepository.fetchAwards() {
            await MainActor.run {
                self.awards = remoteAwards
            }
        }
    }
}

// MARK: - Profile Stat Model
struct ProfileStat: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let value: String
    let color: Color
}

// MARK: - Challenge Model
struct Challenge: Identifiable {
    let id = UUID()
    let icon: String?
    let title: String
    let subtitle: String
    let color: Color
    let bgColor: Color
    let isCompleted: Bool
} 