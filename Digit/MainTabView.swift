import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authCoordinator: AuthCoordinator
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State private var showCalendarSheet = false
    
    var headerName: String {
        let name: String
        if let profile = authViewModel.currentUserProfile {
            name = "\(profile.first_name) \(profile.last_name)"
        } else {
            name = "Welcome!" // Placeholder until user is logged in
        }
        print("[DEBUG] MainTabView headerName computed: \(name)")
        return name
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DigitHeaderView(name: headerName, onCalendarTap: { showCalendarSheet = true })
            // Tab bar separator
            Divider()
                .background(Color.digitDivider)
            ZStack(alignment: .bottom) {
                TabView {
                    NavigationView {
                        HomeView()
                            .navigationBarHidden(true)
                    }
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    
                    NavigationView {
                        StatsView()
                            .navigationBarHidden(true)
                    }
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar.fill")
                    }
                    
                    NavigationView {
                        AwardsView()
                            .navigationBarHidden(true)
                    }
                    .tabItem {
                        Label("Awards", systemImage: "rosette")
                    }
                    
                    NavigationView {
                        SettingsView()
                            .navigationBarHidden(true)
                    }
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
                .tint(Color.digitBrand)
                // Subtle tab bar background
                .background(
                    Color.digitBackground
                        .overlay(
                            Color.digitBrand.opacity(0.04) // subtle tint for separation
                        )
                )
            }
        }
        .background(Color.digitBackground.ignoresSafeArea())
        .sheet(isPresented: $showCalendarSheet) {
            CalenderProgressView()
        }
    }
}

#if DEBUG
#Preview {
    let mockAuthViewModel = AuthViewModel()
    MainTabView()
        .environmentObject(AuthCoordinator(authViewModel: mockAuthViewModel))
        .environmentObject(mockAuthViewModel)
}
#endif 
