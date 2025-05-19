import SwiftUI
import ConfettiSwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authCoordinator: AuthCoordinator
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @StateObject private var homeViewModel = HomeViewModel(
        habitService: HabitService(),
        progressService: HabitProgressService(),
        userId: UUID() // Temporary dummy value
    )
    @State private var isLoading = true
    @State private var showCalendarSheet = false
    @State private var confettiTrigger = 0
    @State private var showNewHabitSheet = false
    @State private var selectedTab: Int = 0
    @StateObject private var accountViewModel = AccountViewModel(
        profileService: SupabaseProfileService(),
        authService: SupabaseAuthService()
    )
    
    var headerName: String {
        let name: String
        if let profile = authViewModel.currentUserProfile {
            if let userName = profile.user_name, !userName.isEmpty {
                name = userName
            } else {
                name = "\(profile.first_name) \(profile.last_name)"
            }
        } else {
            name = "Welcome!" // Placeholder until user is logged in
        }
        print("[DEBUG] MainTabView headerName computed: \(name)")
        return name
    }
    
    var body: some View {
        Group {
        if isLoading {
            ProgressView("Loading...")
        } else {
            ZStack {
                VStack(spacing: 0) {
                    DigitHeaderView(name: headerName, onCalendarTap: { showCalendarSheet = true }, onPlusTap: { showNewHabitSheet = true })
                    // Tab bar separator
                    Divider()
                        .background(Color.digitDivider)
                    ZStack(alignment: .bottom) {
                        TabView(selection: $selectedTab) {
                            NavigationView {
                                HomeView(onHabitCompleted: { confettiTrigger += 1 }, viewModel: homeViewModel)
                                    .navigationBarHidden(true)
                            }
                            .tabItem {
                                Label("Home", systemImage: "house.fill")
                            }
                            .tag(0)
                            
                            NavigationView {
                                StatsView()
                                    .navigationBarHidden(true)
                            }
                            .tabItem {
                                Label("Stats", systemImage: "chart.bar.fill")
                            }
                            .tag(1)
                            
                            NavigationView {
                                AwardsView()
                                    .navigationBarHidden(true)
                            }
                            .tabItem {
                                Label("Awards", systemImage: "rosette")
                            }
                            .tag(2)
                            
                            NavigationView {
                                SettingsView()
                                    .navigationBarHidden(true)
                                    .environmentObject(accountViewModel)
                            }
                            .tabItem {
                                Label("Settings", systemImage: "gearshape.fill")
                            }
                            .tag(3)
                        }
                        .tint(Color.digitBrand)
                        .animation(nil, value: selectedTab)
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
                        if let userIdString = authViewModel.currentUserProfile?.id,
                           let userId = UUID(uuidString: userIdString) {
                        CalenderProgressView(userId: userId)
                    } else {
                        Text("User not found")
                    }
                }
                .sheet(isPresented: $showNewHabitSheet) {
                    NewHabitView(onDismiss: { showNewHabitSheet = false }, userId: authViewModel.currentUserProfile?.id ?? "", homeViewModel: homeViewModel)
                }
            }
            .confettiCannon(trigger: $confettiTrigger, num: 30, colors: [.red, .blue, .green, .yellow, .purple])
            }
        }
        .onAppear {
            Task {
                do {
                    let session = try await SupabaseManager.shared.client.auth.session
                    let userId = session.user.id
                    await MainActor.run {
                        homeViewModel.updateUserId(userId)
                        isLoading = false
                    }
                } catch {
                    // Optionally handle error (e.g., show an error message)
                }
            }
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
