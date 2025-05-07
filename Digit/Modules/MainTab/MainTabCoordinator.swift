import SwiftUI

struct MainTabCoordinator: View {
    @State private var selectedTab: MainTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .stats:
                    StatsView()
                case .achievements:
                    AchievementsView()
                case .settings:
                    SettingsView()
                }
            }
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Placeholder Views for Other Tabs

struct StatsView: View {
    var body: some View {
        VStack {
            Text("Stats")
                .font(.title)
                .foregroundColor(.brandBlue)
            Spacer()
        }
        .padding()
    }
}

struct AchievementsView: View {
    var body: some View {
        VStack {
            Text("Achievements")
                .font(.title)
                .foregroundColor(.brandBlue)
            Spacer()
        }
        .padding()
    }
} 