import SwiftUI

struct HabitView: View {
    @StateObject private var viewModel: HabitViewModel
    @Environment(\.scenePhase) private var scenePhase
    
    init(userId: String) {
        _viewModel = StateObject(wrappedValue: HabitViewModel(userId: userId))
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
                            
                            // Stats Cards
                            HStack(spacing: DigitLayout.Spacing.large) {
                                // Streak Card
                                statsCard(
                                    title: "Current Streak",
                                    value: "\(habit.currentStreak)",
                                    subtitle: "Best: \(habit.bestStreak) days",
                                    icon: "flame.fill",
                                    color: .digitHabitYellow
                                )
                                
                                // Completion Rate Card
                                statsCard(
                                    title: "Completion Rate",
                                    value: "\(Int(habit.completionRate * 100))%",
                                    subtitle: "Keep it up!",
                                    icon: "chart.bar.fill",
                                    color: .digitHabitGreen
                                )
                            }
                            .padding(.horizontal, DigitLayout.Padding.horizontal)
                            
                            // Delete Button
                            Button(role: .destructive, action: {
                                Task {
                                    await viewModel.deleteCurrentHabit()
                                }
                            }) {
                                Text("Delete Habit")
                                    .font(.digitBody)
                                    .foregroundStyle(.red)
                            }
                            .padding(.top, DigitLayout.Spacing.large)
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
                                .padding(.horizontal, DigitLayout.Padding.horizontal)
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
            Text(habit.title)
                .font(.digitTitle2)
                .foregroundStyle(Color.digitBrand)
            
            Text("Preferred time: \(habit.preferredTime.rawValue)")
                .font(.digitSubheadline)
                .foregroundStyle(.secondary)
            
            Button(action: {
                Task {
                    await viewModel.toggleHabitCompletion()
                }
            }) {
                HStack {
                    Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.digitIconMedium)
                    Text(habit.isCompletedToday ? "Completed Today" : "Mark as Complete")
                        .font(.digitHeadline)
                }
                .digitButton(background: habit.isCompletedToday ? .digitHabitGreen : .digitBrand)
            }
        }
        .digitCard()
        .padding(.horizontal, DigitLayout.Padding.horizontal)
    }
    
    private func statsCard(title: String, value: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: DigitLayout.Spacing.small) {
            HStack {
                Image(systemName: icon)
                    .font(.digitIconExtraSmall)
                    .foregroundStyle(color)
                Text(title)
                    .font(.digitSubheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text(value)
                .font(.digitLargeTitle)
                .foregroundStyle(Color.digitBrand)
            
            Text(subtitle)
                .font(.digitCaption)
                .foregroundStyle(.secondary)
        }
        .digitCard()
    }
    
    private var createHabitSheet: some View {
        NavigationView {
            ZStack {
                Color.digitBackground
                    .ignoresSafeArea()
                
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
                        
                        TextField("", text: $viewModel.newHabitTitle)
                            .font(.digitTitle)
                            .placeholder(when: viewModel.newHabitTitle.isEmpty) {
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
                    .padding(.horizontal, DigitLayout.Padding.horizontal)
                    
                    VStack(alignment: .leading, spacing: DigitLayout.Spacing.small) {
                        Text("Preferred Time")
                            .font(.digitSubheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, DigitLayout.Padding.horizontal)
                        
                        ForEach(PreferredHabitTime.allCases, id: \.self) { time in
                            Button(action: {
                                viewModel.selectedTime = time
                            }) {
                                HStack {
                                    Text(time.rawValue)
                                        .font(.digitBody)
                                    Spacer()
                                    if viewModel.selectedTime == time {
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
                            .padding(.horizontal, DigitLayout.Padding.horizontal)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await viewModel.createNewHabit()
                        }
                    }) {
                        Text("Create Habit")
                            .font(.digitHeadline)
                            .digitButton()
                    }
                    .padding(.horizontal, DigitLayout.Padding.horizontal)
                    .padding(.bottom, DigitLayout.Spacing.large)
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