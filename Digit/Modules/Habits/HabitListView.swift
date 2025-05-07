//
//  HabitListView.swift
//  Digit
//
//  Main dashboard view showing all habits.
//

import SwiftUI

struct HabitListView: View {
    @StateObject var viewModel: HabitListViewModel
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.habits.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "sparkles")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(Color.accentColor)
                            .accessibilityHidden(true)
                        Text(NSLocalizedString("empty_state_title", comment: "No habits yet"))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        Text(NSLocalizedString("empty_state_message", comment: "Add your first habit to get started!"))
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button(action: { showingAddHabit = true }) {
                            Label(NSLocalizedString("add_habit_button", comment: "Add Habit"), systemImage: "plus")
                                .font(.headline)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .accessibilityHint(NSLocalizedString("add_habit_empty_hint", comment: "Add your first habit"))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.habits) { habit in
                        NavigationLink(value: habit) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(habit.color.color)
                                        .frame(width: 40, height: 40)
                                    Image(systemName: habit.iconName)
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .bold))
                                        .accessibilityHidden(true)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(habit.name)
                                        .font(.headline)
                                        .accessibilityLabel(habit.name)
                                    Text(habit.frequency.rawValue.capitalized)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                let completedToday = habit.completions.contains(where: { Calendar.current.isDateInToday($0) })
                                Button(action: {
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                    viewModel.markHabitCompleted(habit)
                                }) {
                                    Image(systemName: completedToday ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(completedToday ? .green : .gray)
                                        .font(.title2)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(completedToday ? NSLocalizedString("habit_completed_label", comment: "Habit completed today") : NSLocalizedString("mark_habit_done_label", comment: "Mark habit as done"))
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(Constants.dashboardTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showingAddHabit = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(NSLocalizedString("add_habit_button", comment: "Add Habit"))
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel(NSLocalizedString("settings_title", comment: "Settings"))
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                HabitCreateView(
                    viewModel: HabitCreateViewModel(),
                    onSave: { habit in
                        viewModel.addHabit(habit)
                        showingAddHabit = false
                    },
                    onCancel: {
                        showingAddHabit = false
                    }
                )
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(
                    viewModel: HabitDetailViewModel(
                        habit: habit,
                        onUpdate: { updated in viewModel.updateHabit(updated) },
                        onDelete: {
                            viewModel.deleteHabit(habit)
                        }
                    )
                )
            }
        }
    }
} 