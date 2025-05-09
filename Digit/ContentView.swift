import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        Group {
            if coordinator.showOnboarding {
                OnboardingView(viewModel: OnboardingViewModel(
                    onComplete: coordinator.completeOnboarding,
                    onDismiss: { coordinator.showOnboarding = false }
                ))
            } else {
                MainTabView()
            }
        }
    }
}

#if DEBUG
#Preview {
    ContentView()
        .environmentObject(AppCoordinator())
}
#endif 