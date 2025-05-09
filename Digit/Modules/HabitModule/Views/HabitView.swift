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
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if let habit = viewModel.currentHabit {
                            // Current Habit Card
                            habitCard(habit)
                            
                            // Stats Cards
                            HStack(spacing: 16) {
                                // Streak Card
                                statsCard(
                                    title: "Current Streak",
                                    value: "\(habit.currentStreak)",
                                    subtitle: "Best: \(habit.bestStreak) days",
                                    icon: "flame.fill",
                                    color: .orange
                                )
                                
                                // Completion Rate Card
                                statsCard(
                                    title: "Completion Rate",
                                    value: "\(Int(habit.completionRate * 100))%",
                                    subtitle: "Keep it up!",
                                    icon: "chart.bar.fill",
                                    color: .green
                                )
                            }
                            .padding(.horizontal)
                            
                            // Delete Button
                            Button(role: .destructive, action: {
                                Task {
                                    await viewModel.deleteCurrentHabit()
                                }
                            }) {
                                Text("Delete Habit")
                                    .foregroundStyle(.red)
                            }
                            .padding(.top)
                        } else {
                            // Empty State
                            VStack(spacing: 24) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 48))
                                    .foregroundStyle(Color.brand)
                                
                                Text("Start Your Journey")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.brand)
                                
                                Text("Create your first habit to begin tracking your progress.")
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                                
                                Button(action: {
                                    viewModel.showingCreateHabit = true
                                }) {
                                    Text("Create Habit")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(Color.brand)
                                        .foregroundStyle(.white)
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal)
                            }
                            .padding()
                        }
                    }
                    .padding(.top)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Your Habit")
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
        VStack(spacing: 16) {
            Text(habit.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.brand)
            
            Text("Preferred time: \(habit.preferredTime.rawValue)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button(action: {
                Task {
                    await viewModel.toggleHabitCompletion()
                }
            }) {
                HStack {
                    Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                    Text(habit.isCompletedToday ? "Completed Today" : "Mark as Complete")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(habit.isCompletedToday ? Color.green : Color.brand)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .padding(.horizontal)
    }
    
    private func statsCard(title: String, value: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color.brand)
            
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
    
    private var createHabitSheet: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("What habit would you like to build?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.brand)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Habit Title")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        TextField("", text: $viewModel.newHabitTitle)
                            .font(.system(size: 24))
                            .placeholder(when: viewModel.newHabitTitle.isEmpty) {
                                Text("e.g., Exercise daily")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(height: 56)
                            .background(.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.brand, lineWidth: 1.7)
                            )
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preferred Time")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        ForEach(PreferredHabitTime.allCases, id: \.self) { time in
                            Button(action: {
                                viewModel.selectedTime = time
                            }) {
                                HStack {
                                    Text(time.rawValue)
                                        .font(.system(size: 18))
                                    Spacer()
                                    if viewModel.selectedTime == time {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundStyle(Color.brand)
                                    }
                                }
                                .padding()
                                .frame(height: 56)
                                .background(.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.brand, lineWidth: 1.7)
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await viewModel.createNewHabit()
                        }
                    }) {
                        Text("Create Habit")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.brand)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationBarItems(
                trailing: Button("Cancel") {
                    viewModel.showingCreateHabit = false
                }
            )
        }
    }
}

#if DEBUG
#Preview {
    HabitView(userId: "preview_user")
}
#endif 