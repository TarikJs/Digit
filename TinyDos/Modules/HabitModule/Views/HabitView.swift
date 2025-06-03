import SwiftUI

struct HabitView: View {
    @StateObject private var viewModel: HabitViewModel
    @Environment(\.scenePhase) private var scenePhase
    
    init(userId: String) {
        _viewModel = StateObject(wrappedValue: HabitViewModel(habitRepository: HabitRepository(), userId: userId))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.digitBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DigitLayout.Spacing.xl) {
                        if let habit = viewModel.currentHabit {
                            // Current Habit Card
                            habitCard(habit)
                        } else {
                            // Empty State
                            VStack(spacing: DigitLayout.Spacing.xl) {
                                Image(systemName: "sparkles")
                                    .font(.digitIconLarge)
                                    .foregroundStyle(Color.digitBrand)
                                
                                Text("Start Your Journey")
                                    .font(.digitTitle)
                                    .foregroundStyle(Color.digitBrand)
                                
                                Text("Create your first habit to begin tracking your progress.")
                                    .font(.digitBody)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                                
                                Button(action: {
                                    viewModel.showingCreateHabit = true
                                }) {
                                    Text("Create Habit")
                                        .font(.digitHeadline)
                                        .digitButton()
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding()
                        }
                    }
                    .padding(.top, DigitLayout.Spacing.large)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Your Habit")
            .outlinedNavigationBar()
            .sheet(isPresented: $viewModel.showingCreateHabit) {
                createHabitSheet
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task {
                await viewModel.loadCurrentHabit()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    Task {
                        await viewModel.loadCurrentHabit()
                    }
                }
            }
        }
    }
    
    private func habitCard(_ habit: Habit) -> some View {
        VStack(spacing: DigitLayout.Spacing.large) {
            Text(habit.name)
                .font(.digitTitle2)
                .foregroundStyle(Color.digitBrand)
        }
        .digitCard()
        .padding(.horizontal, 16)
    }
    
    private var createHabitSheet: some View {
        NavigationView {
            ZStack {
                Color.digitBackground
                    .ignoresSafeArea()
                
                CreateHabitForm { name, preferredTime in
                    Task {
                        await viewModel.createNewHabit(
                            name: name,
                            dailyGoal: 1,
                            icon: "figure.walk", // placeholder
                            startDate: Date(),
                            endDate: nil,
                            repeatFrequency: "daily",
                            weekdays: nil,
                            reminderTime: nil,
                            unit: nil,
                            tag: nil
                        )
                    }
                }
            }
            .navigationBarItems(
                trailing: Button("Cancel") {
                    viewModel.showingCreateHabit = false
                }
                .foregroundStyle(Color.digitBrand)
            )
        }
    }
}

#if DEBUG
#Preview {
    HabitView(userId: "preview_user")
}
#endif

// MARK: - CreateHabitForm
struct CreateHabitForm: View {
    var onCreate: (String, PreferredHabitTime) -> Void
    @State private var name: String = ""
    @State private var preferredTime: PreferredHabitTime = .morning
    var body: some View {
        VStack(spacing: DigitLayout.Spacing.xl) {
            Text("What habit would you like to build?")
                .font(.digitTitle2)
                .foregroundStyle(Color.digitBrand)
                .multilineTextAlignment(.center)
                .padding(.top, DigitLayout.Spacing.large)
            VStack(alignment: .leading, spacing: DigitLayout.Spacing.small) {
                Text("Habit Title")
                    .font(.digitSubheadline)
                    .foregroundStyle(.secondary)
                TextField("", text: $name)
                    .font(.digitTitle)
                    .placeholder(when: name.isEmpty) {
                        Text("e.g., Exercise daily")
                            .font(.digitTitle)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(height: DigitLayout.Size.buttonHeight)
                    .background(.white)
                    .cornerRadius(DigitLayout.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: DigitLayout.cornerRadius)
                            .stroke(Color.digitBrand, lineWidth: DigitLayout.borderWidth)
                    )
            }
            .padding(.horizontal, 16)
            VStack(alignment: .leading, spacing: DigitLayout.Spacing.small) {
                Text("Preferred Time")
                    .font(.digitSubheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                ForEach(PreferredHabitTime.allCases, id: \ .self) { time in
                    Button(action: {
                        preferredTime = time
                    }) {
                        HStack {
                            Text(time.rawValue)
                                .font(.digitBody)
                            Spacer()
                            if preferredTime == time {
                                Image(systemName: "checkmark")
                                    .font(.digitIconExtraSmall)
                                    .foregroundStyle(Color.digitBrand)
                            }
                        }
                        .padding()
                        .frame(height: DigitLayout.Size.buttonHeight)
                        .background(.white)
                        .cornerRadius(DigitLayout.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: DigitLayout.cornerRadius)
                                .stroke(Color.digitBrand, lineWidth: DigitLayout.borderWidth)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                }
            }
            Spacer()
            Button(action: {
                onCreate(name, preferredTime)
            }) {
                Text("Create Habit")
                    .font(.digitHeadline)
                    .digitButton()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, DigitLayout.Spacing.large)
        }
    }
} 