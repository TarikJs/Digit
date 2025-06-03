import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var selectedDate: Date = Date()
    @State private var isEditMode: Bool = false
    @State private var showingNewHabitSheet = false
    // Dummy HomeViewModel for preview/testing
    @StateObject private var homeViewModel = HomeViewModel(habitRepository: HabitRepository(), progressRepository: ProgressRepository(), userId: UUID())
    @State private var customTags: [String] = []
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    // Home tab
                    VStack(spacing: 0) {
                        DigitHeaderView(date: selectedDate, onPlusTap: { showingNewHabitSheet = true })
                        CalendarStrip(selectedDate: $selectedDate)
                            .padding(.top, 16)
                        HomeView(
                            onHabitCompleted: {},
                            viewModel: homeViewModel,
                            isEditMode: $isEditMode,
                            headerPlusAction: { showingNewHabitSheet = true },
                            customTags: customTags,
                            setCustomTags: { customTags = $0 }
                        )
                        .frame(maxHeight: .infinity)
                        .layoutPriority(1)
                    }
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                    // Stats tab
                    ProgressView()
                        .tabItem {
                            Image(systemName: "chart.pie")
                            Text("Progress")
                        }
                        .tag(1)
                    // Streaks tab
                    AwardsView()
                        .tabItem {
                            Image(systemName: "star")
                            Text("Streaks")
                        }
                        .tag(2)
                    // Settings tab
                    SettingsView()
                        .environmentObject(AccountViewModel(
                            profileService: SupabaseProfileService(),
                            authService: AuthService()
                        ))
                        .tabItem {
                            Image(systemName: "gearshape")
                            Text("Settings")
                        }
                        .tag(3)
                }
                .accentColor(Color.digitBrand)
            }
        }
        .sheet(isPresented: $showingNewHabitSheet) {
            NewHabitView(
                onDismiss: { showingNewHabitSheet = false },
                userId: homeViewModel.userId.uuidString,
                homeViewModel: homeViewModel,
                customTags: customTags,
                setCustomTags: { customTags = $0 }
            )
        }
    }
}

private struct CalendarStrip: View {
    @Binding var selectedDate: Date
    var body: some View {
        HStack(spacing: 0) {
            ForEach(-3...3, id: \ .self) { offset in
                let date = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) ?? selectedDate
                let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                let isToday = Calendar.current.isDateInToday(date)
                let textColor: Color = isToday ? Color.digitBrand : (isSelected ? Color.digitBrand : Color.digitSecondaryText)
                VStack(spacing: 2) {
                    Text(dayNumber(from: date))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(textColor)
                    Text(dayShortName(from: date))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(textColor)
                    // Placeholder for completion/total
                    Text("0/0")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(textColor)
                    Rectangle()
                        .fill(isToday ? Color.digitBrand : (isSelected ? Color.digitBrand : Color.clear))
                        .frame(height: 3)
                        .cornerRadius(1.5)
                        .padding(.top, 14)
                }
                .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selectedDate = date
                    }
                }
                .accessibilityElement()
                .accessibilityLabel("\(dayShortName(from: date)), 0 completed out of 0")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.bottom, 0)
        // Thin green line under calendar
        Rectangle()
            .fill(Color.digitBrand)
            .frame(height: 1)
            .padding(.horizontal, 0)
    }
    private func dayNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    private func dayShortName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EE"
        return formatter.string(from: date).uppercased()
    }
}

#if DEBUG
#Preview {
    MainTabView()
}
#endif 
