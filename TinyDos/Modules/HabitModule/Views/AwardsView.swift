import SwiftUI

struct AwardCard: View {
    let icon: String?
    let title: String
    let subtitle: String?
    let isCompleted: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                Spacer()
                if let icon = icon {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(Color.digitBrand)
                } else {
                    Image(systemName: "questionmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(Color.digitBrand)
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.digitBrand)
                    .multilineTextAlignment(.center)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.digitSecondaryText)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isCompleted ? Color.digitHabitGreen : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.digitBrand, lineWidth: 2)
            )
            if isCompleted {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(Color.digitBrand, lineWidth: 2)
                        )
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.digitBrand)
                }
                .offset(x: -8, y: 8)
            }
        }
        .aspectRatio(1, contentMode: .fit) // Makes the card a square
    }
}

struct LeaderboardAward: Identifiable {
    let id: UUID
    let awardType: String
    let awardedAt: Date
}

struct LeaderboardEntry: Identifiable {
    let id: UUID
    let userName: String
    let avatarURL: URL?
    let points: Int
    let awards: [LeaderboardAward]
}

struct LeaderboardView: View {
    let entries: [LeaderboardEntry]

    var body: some View {
        NavigationView {
            List(entries.sorted { $0.points > $1.points }) { entry in
                HStack(alignment: .center, spacing: 16) {
                    if let url = entry.avatarURL {
                        AsyncImage(url: url) { image in
                            image.resizable().clipShape(Circle())
                        } placeholder: {
                            Circle().fill(Color.gray)
                        }
                        .frame(width: 44, height: 44)
                    } else {
                        Circle().fill(Color.gray)
                            .frame(width: 44, height: 44)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.userName)
                            .font(.headline)
                        Text("\(entry.points) pts")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(entry.awards) { award in
                                    AwardBadgeView(award: award)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Leaderboard")
        }
    }
}

struct AwardBadgeView: View {
    let award: LeaderboardAward
    var body: some View {
        Text(award.awardType)
            .font(.caption2)
            .padding(6)
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(8)
    }
}

struct Streak: Identifiable {
    let id = UUID()
    let habitName: String
    var currentStreak: Int
    let longestStreak: Int
    let icon: String
}

struct AwardsView: View {
    @State private var selectedStreakID: UUID? = nil
    @State private var streaks: [Streak] = [
        .init(habitName: "Drink Water", currentStreak: 0, longestStreak: 30, icon: "drop.fill"),
        .init(habitName: "Read Book", currentStreak: 0, longestStreak: 15, icon: "book.fill"),
        .init(habitName: "Exercise", currentStreak: 0, longestStreak: 21, icon: "figure.walk"),
        .init(habitName: "Meditate", currentStreak: 0, longestStreak: 10, icon: "brain.head.profile"),
        .init(habitName: "Sleep Early", currentStreak: 0, longestStreak: 14, icon: "bed.double.fill"),
        .init(habitName: "No Sugar", currentStreak: 0, longestStreak: 8, icon: "cube.fill"),
        .init(habitName: "Journaling", currentStreak: 0, longestStreak: 12, icon: "pencil.and.outline"),
        .init(habitName: "Yoga", currentStreak: 0, longestStreak: 9, icon: "figure.yoga"),
        .init(habitName: "Walk Dog", currentStreak: 0, longestStreak: 11, icon: "pawprint.fill"),
        .init(habitName: "Healthy Meal", currentStreak: 0, longestStreak: 16, icon: "leaf.fill")
    ]
    // Only streaks with currentStreak > 0 are considered active and tracked in the main habits list under the 'streaks' tag
    private var activeStreaks: [Streak] {
        streaks.filter { $0.currentStreak > 0 }
    }
    // Refactored: Move the streaks list into a computed property to help the compiler
    private var streaksList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(Array(streaks.enumerated()), id: \.element.id) { idx, streak in
                    StreakCard(
                        streak: streak,
                        isSelected: selectedStreakID == streak.id,
                        isGrayedOut: streak.currentStreak == 0,
                        tag: streak.currentStreak > 0 ? "Streaks" : nil
                    )
                    .onTapGesture {
                        if streak.currentStreak == 0 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                streaks[idx].currentStreak = 1
                            }
                        } else {
                            selectedStreakID = streak.id
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Streaks")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.black)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }
            .padding(.top, 0)
            .padding(.horizontal, 16)
            Spacer().frame(height: 24)
            streaksList
            Spacer()
        }
        .background(Color.digitGrayLight)
    }
}

private struct StreakCard: View {
    let streak: Streak
    let isSelected: Bool
    let isGrayedOut: Bool
    let tag: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.digitBrand.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: streak.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color.digitBrand)
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(streak.habitName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.black)
                        if let tag = tag {
                            Text(tag)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.digitBrand)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.digitBrand.opacity(0.08))
                                .cornerRadius(8)
                        }
                    }
                    Text("Current Streak: \(streak.currentStreak) days")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.digitSecondaryText)
                    Text("Longest: \(streak.longestStreak) days")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.digitSecondaryText)
                }
                Spacer()
                if isAchieved {
                    Image(systemName: achievementIcon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "128D65"))
                        .accessibilityLabel("Streak achieved")
                }
            }
            ProgressBar(progress: progressValue)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.digitBrand : Color.clear, lineWidth: 2)
                .overlay(
                    isSelected ? RoundedRectangle(cornerRadius: 16)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                        .foregroundColor(Color.digitBrand) : nil
                )
        )
        .shadow(color: Color.black.opacity(0.03), radius: 2, y: 2)
        .overlay(
            Group {
                if isGrayedOut {
                    Color.white.opacity(0.6)
                        .cornerRadius(16)
                        .animation(.easeInOut(duration: 0.3), value: isGrayedOut)
                }
            }
        )
    }
    private var progressValue: Double {
        guard streak.longestStreak > 0 else { return 0 }
        return min(Double(streak.currentStreak) / Double(streak.longestStreak), 1.0)
    }
    private var isAchieved: Bool {
        streak.currentStreak == streak.longestStreak && streak.currentStreak > 0 || streak.currentStreak == 30
    }
    private var achievementIcon: String {
        streak.currentStreak == 30 ? "trophy.fill" : "checkmark.seal.fill"
    }
}

private struct ProgressBar: View {
    let progress: Double
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color(.systemGray5))
                .frame(height: 6)
            Capsule()
                .fill(Color.digitBrand)
                .frame(width: max(CGFloat(progress) * 180, 8), height: 6)
        }
        .frame(height: 6)
    }
}

struct UserAwardsSheet: View {
    let user: LeaderboardEntry
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text(user.userName)
                    .font(.title2.bold())
                Text("Awards")
                    .font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(user.awards) { award in
                            AwardBadgeView(award: award)
                        }
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("User Awards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        // Dismiss handled by .sheet
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    AwardsView()
}
#endif 

// Add color helpers for medals
extension Color {
    static let leaderboardGold = Color(hex: "FFD700")
    static let leaderboardSilver = Color(hex: "C0C0C0")
    static let leaderboardBronze = Color(hex: "CD7F32")
} 
