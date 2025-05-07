import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            VStack {
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
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    MainTabView()
} 
    