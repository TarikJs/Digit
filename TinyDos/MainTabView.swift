import SwiftUI
import ConfettiSwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authCoordinator: AuthCoordinator
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @StateObject private var homeViewModel = HomeViewModel(habitRepository: HabitRepository(), progressRepository: ProgressRepository(), userId: UUID())
    @State private var isLoading: Bool
    @State private var confettiTrigger = 0
    @State private var showNewHabitSheet = false
    @State private var selectedTab: Int = 0
    @StateObject private var accountViewModel = AccountViewModel(
        profileService: SupabaseProfileService(),
        authService: SupabaseAuthService()
    )
    @State private var isEditMode: Bool = false
    
    // Custom initializer for preview/test
    init(isLoading: Bool = true) {
        _isLoading = State(initialValue: isLoading)
    }
    
    var headerName: String {
        let name: String
        if let profile = authViewModel.currentUserProfile {
            if let userName = profile.userName, !userName.isEmpty {
                name = userName
            } else {
                name = "\(profile.firstName) \(profile.lastName)"
            }
        } else {
            name = "Welcome!" // Placeholder until user is logged in
        }
        print("[DEBUG] MainTabView headerName computed: \(name)")
        return name
    }
    
    var body: some View {
        if isLoading {
            ProgressView("Loading...")
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
        } else {
            ZStack {
                VStack(spacing: 0) {
                    DigitHeaderView(
                        name: headerName,
                        topPadding: 16,
                        bottomPadding: 8,
                        onPlusTap: { showNewHabitSheet = true },
                        isEditMode: isEditMode,
                        onTrashTap: { print("[DEBUG] Trash tapped") }
                    )
                    // Tab bar separator
                    Divider()
                        .background(Color.digitDivider)
                    ZStack(alignment: .bottom) {
                        TabView(selection: $selectedTab) {
                            NavigationView {
                                HomeView(onHabitCompleted: { confettiTrigger += 1 }, viewModel: homeViewModel, isEditMode: $isEditMode)
                                    .navigationBarHidden(true)
                            }
                            .tabItem {
                                Label("Home", systemImage: "house.fill")
                            }
                            .tag(0)
                            
                            NavigationView {
                                StatsView(
                                    habitService: HabitService(),
                                    progressService: HabitProgressService(),
                                    userId: {
                                        if let idString = authViewModel.currentUserProfile?.id, let uuid = UUID(uuidString: idString) {
                                            return uuid
                                        } else {
                                            return UUID()
                                        }
                                    }()
                                )
                                .navigationBarHidden(true)
                            }
                            .tabItem {
                                Label("Stats", systemImage: "chart.bar.fill")
                            }
                            .tag(1)
                            
                            NavigationView {
                                AwardsView()
                            }
                            .tabItem {
                                Label("Streaks", systemImage: "flame.fill")
                            }
                            .tag(2)
                            
                            NavigationView {
                                SettingsView()
                                    .environmentObject(accountViewModel)
                                    .navigationBarHidden(true)
                            }
                            .tabItem {
                                Label("Settings", systemImage: "person.fill")
                            }
                            .tag(3)
                        }
                        .accentColor(Color.digitBrand)
                    }
                }
                .sheet(isPresented: $showNewHabitSheet) {
                    NewHabitView(onDismiss: { showNewHabitSheet = false }, userId: authViewModel.currentUserProfile?.id ?? "", homeViewModel: homeViewModel)
                }
            }
            .confettiCannon(trigger: $confettiTrigger, num: 30, colors: [.red, .blue, .green, .yellow, .purple])
        }
    }
}

#if DEBUG
#Preview {
    let mockAuthViewModel = AuthViewModel()
    MainTabView(isLoading: false)
        .environmentObject(AuthCoordinator(authViewModel: mockAuthViewModel))
        .environmentObject(mockAuthViewModel)
}
#endif 
