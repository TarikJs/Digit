import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authCoordinator: AuthCoordinator
    
    var body: some View {
        TabView {
            NavigationView {
                HabitView(userId: "user123") // TODO: Replace with actual user ID from auth
            }
            .tabItem {
                Label("Habit", systemImage: "sparkles")
            }
            
            NavigationView {
                Text("Statistics coming soon")
                    .navigationTitle("Statistics")
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            
            NavigationView {
                VStack {
                    Text("Profile")
                        .navigationTitle("Profile")
                    
                    Button(role: .destructive, action: {
                        // TODO: Implement proper sign out
                        authCoordinator.currentState = .auth
                    }) {
                        Text("Sign Out")
                            .foregroundStyle(.red)
                    }
                    .padding()
                }
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .tint(Color.brand)
    }
}

#if DEBUG
#Preview {
    MainTabView()
        .environmentObject(AuthCoordinator())
}
#endif 