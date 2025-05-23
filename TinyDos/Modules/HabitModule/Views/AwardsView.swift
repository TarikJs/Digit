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
    @State private var selectedTab: Tab = .leaderboard
    @State private var selectedUser: LeaderboardEntry? = nil
    @State private var showUserAwards = false
    @Namespace private var segmentNamespace

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    enum Tab: String, CaseIterable, Identifiable {
        case leaderboard = "Leaderboard"
        case myAwards = "My Awards"
        var id: String { rawValue }
    }

    // Mock leaderboard data for now
    private var leaderboardEntries: [LeaderboardEntry] {
        let awards = [
            LeaderboardAward(id: UUID(), awardType: "Streak 7", awardedAt: Date()),
            LeaderboardAward(id: UUID(), awardType: "First Habit", awardedAt: Date())
        ]
        return [
            LeaderboardEntry(id: UUID(), userName: "Alice", avatarURL: nil, points: 120, awards: awards),
            LeaderboardEntry(id: UUID(), userName: "Bob", avatarURL: nil, points: 90, awards: [awards[0]]),
            LeaderboardEntry(id: UUID(), userName: "Charlie", avatarURL: nil, points: 60, awards: [])
        ]
    }

    var body: some View {
        ZStack {
            Color.digitGrayLight.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
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
                        .zIndex(1)
                    Divider().background(Color.digitDivider)
                }
                ScrollView(showsIndicators: false) {
                    // Segmented control (view selector)
                    ZStack {
                        RoundedRectangle(cornerRadius: DigitLayout.cornerRadius, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.03), radius: 2, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: DigitLayout.cornerRadius, style: .continuous)
                                    .stroke(Color.digitBrand.opacity(0.12), lineWidth: 1.5)
                            )
                        HStack(spacing: 0) {
                            ForEach(Tab.allCases) { tab in
                                Button(action: { withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { selectedTab = tab } }) {
                                    Text(tab.rawValue)
                                        .font(.plusJakartaSans(size: 16, weight: .semibold))
                                        .foregroundStyle(selectedTab == tab ? Color.white : Color.digitBrand)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            ZStack {
                                                if selectedTab == tab {
                                                    RoundedRectangle(cornerRadius: DigitLayout.cornerRadius - 2, style: .continuous)
                                                        .fill(Color.digitAccentRed)
                                                        .shadow(color: Color.digitAccentRed.opacity(0.10), radius: 2, y: 1)
                                                        .padding(.horizontal, 2)
                                                        .padding(.vertical, 2)
                                                        .matchedGeometryEffect(id: "segment", in: segmentNamespace)
                                                } else {
                                                    Color.clear
                                                }
                                            }
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: DigitLayout.cornerRadius - 2, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                    .frame(height: 44)
                    .padding(.horizontal, DigitLayout.Padding.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    // Tab content
                    if selectedTab == .leaderboard {
                        leaderboardList
                    } else {
                        awardsGrid
                    }
                }
            }
        }
    }

    // MARK: - Extracted Leaderboard List
    private var leaderboardList: some View {
        LazyVStack(spacing: 20) {
            ForEach(Array(leaderboardEntries.sorted { $0.points > $1.points }.enumerated()), id: \ .element.id) { (index, entry) in
                let medalColor: Color? =
                    index == 0 ? .leaderboardGold :
                    index == 1 ? .leaderboardSilver :
                    index == 2 ? .leaderboardBronze :
                    nil
                HStack(spacing: 16) {
                    // Rank in circle
                    ZStack {
                        Circle()
                            .fill((medalColor ?? Color.digitAccentRed).opacity(0.12))
                            .frame(width: 32, height: 32)
                        Text("\(index + 1)")
                            .font(.plusJakartaSans(size: 18, weight: .bold))
                            .foregroundStyle(medalColor ?? Color.digitAccentRed)
                    }
                    // Avatar with ring and crown
                    ZStack {
                        Circle()
                            .strokeBorder(medalColor ?? Color.digitBrand.opacity(0.15), lineWidth: 3)
                            .frame(width: 48, height: 48)
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
                        if index == 0 {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.leaderboardGold)
                                .offset(y: -36)
                        }
                    }
                    // Name and points
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.userName)
                            .font(.plusJakartaSans(size: 16, weight: .semibold))
                            .foregroundStyle(Color.digitBrand)
                        Text("\(entry.points) pts")
                            .font(.plusJakartaSans(size: 14, weight: .medium))
                            .foregroundStyle(Color.digitBrand.opacity(0.7))
                    }
                    Spacer()
                    // Awards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(entry.awards) { award in
                                AwardBadgeView(award: award)
                            }
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.digitBrand.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 2, y: 2)
                .padding(.horizontal, DigitLayout.Padding.horizontal)
                .frame(maxWidth: 600)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedUser = entry
                    showUserAwards = true
                }
            }
        }
    }

    // MARK: - Extracted Awards Grid
    private var awardsGrid: some View {
        VStack(alignment: .leading, spacing: 20) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(viewModel.awards.enumerated()), id: \ .element.id) { (index, award) in
                    AwardGridCard(award: award)
                        .aspectRatio(1, contentMode: .fit)
                }
                ForEach(Array(viewModel.challenges.enumerated()), id: \ .element.id) { (index, challenge) in
                    ChallengeGridCard(challenge: challenge)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding(.horizontal, DigitLayout.Padding.horizontal)
            .frame(maxWidth: 600)
        }
    }

    // MARK: - Award Card Helper
    private struct AwardGridCard: View {
        let award: Award
        var body: some View {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Image(systemName: award.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(Color.digitAccentRed)
                    Text(award.title)
                        .font(.plusJakartaSans(size: 15, weight: .semibold))
                        .foregroundStyle(Color.digitBrand)
                        .multilineTextAlignment(.center)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.03), radius: 2, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.digitBrand.opacity(0.12), lineWidth: 1)
                )
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .shadow(color: Color.black.opacity(0.05), radius: 1, y: 1)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.digitAccentRed)
                }
                .offset(x: -8, y: 8)
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }

    // MARK: - Challenge Card Helper
    private struct ChallengeGridCard: View {
        let challenge: Challenge
        var body: some View {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Image(systemName: challenge.icon ?? "questionmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(challenge.isCompleted ? Color.digitAccentRed : Color.digitBrand.opacity(0.3))
                    Text(challenge.title)
                        .font(.plusJakartaSans(size: 15, weight: .semibold))
                        .foregroundStyle(Color.digitBrand)
                        .multilineTextAlignment(.center)
                    if !challenge.subtitle.isEmpty {
                        Text(challenge.subtitle)
                            .font(.plusJakartaSans(size: 13))
                            .foregroundStyle(challenge.isCompleted ? Color.digitAccentRed : Color.digitBrand.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.03), radius: 2, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.digitBrand.opacity(0.12), lineWidth: 1)
                )
                if challenge.isCompleted {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .shadow(color: Color.black.opacity(0.05), radius: 1, y: 1)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.digitAccentRed)
                    }
                    .offset(x: -8, y: 8)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
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
