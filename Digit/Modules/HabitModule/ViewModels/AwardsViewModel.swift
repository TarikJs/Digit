import SwiftUI

final class AwardsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userName: String = "Jane Appleseed"
    @Published var email: String = "jane@digitapp.com"
    @Published var stats: [ProfileStat] = [
        .init(icon: "flame.fill", title: "Streak", value: "21 days", color: .digitHabitGreen),
        .init(icon: "star.fill", title: "Awards", value: "5 badges", color: .digitHabitPurple),
        .init(icon: "heart.fill", title: "Matches", value: "12", color: .digitBrand)
    ]
    @Published var awards: [Award] = [
        .init(icon: "moon.stars", title: "Moonlight warrior", color: .digitHabitPurple, bgColor: .digitHabitPurple),
        .init(icon: "shoeprints.fill", title: "Marathon mindset", color: .digitHabitGreen, bgColor: .digitHabitGreen),
        .init(icon: "sun.max.fill", title: "Sunrise achiever", color: .digitHabitGreen, bgColor: .digitHabitGreen),
        .init(icon: "figure.walk", title: "Step achiever", color: .digitHabitPurple, bgColor: .digitHabitPurple)
    ]
    @Published var challenges: [Challenge] = [
        .init(icon: nil, title: "Strategy Star", subtitle: "Overall harmony", color: .digitBrand, bgColor: .digitBackground, isCompleted: false),
        .init(icon: nil, title: "Aqua Gardian", subtitle: "Body harmony", color: .digitBrand, bgColor: .digitBackground, isCompleted: false),
        .init(icon: nil, title: "Zen Master", subtitle: "Mind harmony", color: .digitBrand, bgColor: .digitBackground, isCompleted: false),
        .init(icon: "pillow.fill", title: "Dreamcatcher", subtitle: "Body harmony", color: .digitHabitGreen, bgColor: .digitHabitGreen, isCompleted: true)
    ]
    
    // MARK: - Initialization
    init() {
        loadProfile()
    }
    
    // MARK: - Private Methods
    private func loadProfile() {
        // TODO: Load from persistence or API
        // For now, using mock data
        userName = UserDefaults.standard.string(forKey: "userName") ?? "Jane Appleseed"
        email = UserDefaults.standard.string(forKey: "userEmail") ?? "jane@digitapp.com"
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

// MARK: - Award Model
struct Award: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
    let bgColor: Color
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