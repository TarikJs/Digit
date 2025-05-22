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

struct AwardsView: View {
    @StateObject private var viewModel = AwardsViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        ZStack {
            Color.digitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                // Black header with accent bar
                VStack(spacing: 0) {
                    Color.digitBrand
                        .frame(height: 48)
                        .ignoresSafeArea(edges: .top)
                        .overlay(
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.digitAccentRed)
                                    .frame(width: 4, height: 24)
                                Text("Streaks & Achievements")
                                    .font(.plusJakartaSans(size: 22, weight: .bold))
                                    .foregroundStyle(Color.white)
                                    .accessibilityAddTraits(.isHeader)
                                Spacer()
                            }
                            .padding(.horizontal, DigitLayout.Padding.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        )
                        .padding(.bottom, 12)
                        .zIndex(1)
                    Divider().background(Color.digitDivider)
                }
                // Card content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.awards) { award in
                                AwardCard(
                                    icon: award.icon,
                                    title: award.title,
                                    subtitle: nil,
                                    isCompleted: true
                                )
                            }
                            ForEach(viewModel.challenges) { challenge in
                                AwardCard(
                                    icon: challenge.icon,
                                    title: challenge.title,
                                    subtitle: challenge.subtitle,
                                    isCompleted: challenge.isCompleted
                                )
                            }
                        }
                        .padding(.horizontal, DigitLayout.Padding.horizontal)
                        .padding(.bottom, 24)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.03), radius: 8, y: 2)
                    )
                    .padding(.vertical, 24)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    AwardsView()
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        let awards = [
            LeaderboardAward(id: UUID(), awardType: "Streak 7", awardedAt: Date()),
            LeaderboardAward(id: UUID(), awardType: "First Habit", awardedAt: Date())
        ]
        let entries = [
            LeaderboardEntry(id: UUID(), userName: "Alice", avatarURL: nil, points: 120, awards: awards),
            LeaderboardEntry(id: UUID(), userName: "Bob", avatarURL: nil, points: 90, awards: [awards[0]]),
            LeaderboardEntry(id: UUID(), userName: "Charlie", avatarURL: nil, points: 60, awards: [])
        ]
        LeaderboardView(entries: entries)
    }
}
#endif 
