import SwiftUI
import ConfettiSwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authCoordinator: AuthCoordinator
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @StateObject private var homeViewModel = HomeViewModel(habitService: HabitService())
    @State private var showCalendarSheet = false
    @State private var confettiTrigger = 0
    @State private var showNewHabitSheet = false
    
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
        ZStack {
            VStack(spacing: 0) {
                DigitHeaderView(name: headerName, onCalendarTap: { showCalendarSheet = true }, onPlusTap: { showNewHabitSheet = true })
                // Tab bar separator
                Divider()
                    .background(Color.digitDivider)
                ZStack(alignment: .bottom) {
                    TabView {
                        NavigationView {
                            HomeView(onHabitCompleted: { confettiTrigger += 1 }, viewModel: homeViewModel)
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
                // Debug/test button for confetti
                /*
                Button("Test Confetti") {
                    confettiTrigger += 1
                    print("[DEBUG] Confetti triggered! Trigger count: \(confettiTrigger)")
                }
                .padding(.top, 12)
                */
            }
            .background(Color.digitBackground.ignoresSafeArea())
            .sheet(isPresented: $showCalendarSheet) {
                CalenderProgressView()
            }
            .sheet(isPresented: $showNewHabitSheet) {
                NewHabitView(onDismiss: { showNewHabitSheet = false }, userId: authViewModel.currentUserProfile?.id ?? "", homeViewModel: homeViewModel)
            }
        }
        .confettiCannon(trigger: $confettiTrigger, num: 30, colors: [.red, .blue, .green, .yellow, .purple])
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
