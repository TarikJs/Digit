//
//  HabitDetailView.swift
//  Digit
//
//  SwiftUI view for a single habit's details and progress.
//

import SwiftUI

struct HabitDetailView: View {
    @ObservedObject var viewModel: HabitDetailViewModel
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    
    private let calendar = Calendar.current
    private let daysToShow = 21 // Show last 3 weeks
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(viewModel.habit.color.color)
                            .frame(width: 48, height: 48)
                        Image(systemName: viewModel.habit.iconName)
                            .foregroundColor(.white)
                            .font(.system(size: 28, weight: .bold))
                            .accessibilityHidden(true)
                    }
                    VStack(alignment: .leading) {
                        Text(viewModel.habit.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(viewModel.habit.frequency.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                // Calendar
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("completion_calendar_label", comment: "Completion calendar label"))
                        .font(.headline)
                    CalendarGrid(viewModel: viewModel, days: daysToShow)
                }
                .padding(.horizontal)
                // Stats
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("stats_label", comment: "Stats label"))
                        .font(.headline)
                    HStack(spacing: 24) {
                        StatView(label: NSLocalizedString("current_streak_label", comment: "Current streak"), value: "\(viewModel.currentStreak)")
                        StatView(label: NSLocalizedString("longest_streak_label", comment: "Longest streak"), value: "\(viewModel.longestStreak)")
                        StatView(label: NSLocalizedString("completion_rate_label", comment: "Completion rate"), value: String(format: "%.0f%%", viewModel.completionRate * 100))
                    }
                }
                .padding(.horizontal)
                Spacer(minLength: 24)
            }
            .padding(.vertical)
        }
        .navigationTitle(NSLocalizedString("habit_detail_title", comment: "Habit Detail"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEdit = true }) {
                    Image(systemName: "pencil")
                }
                .accessibilityLabel(NSLocalizedString("edit_habit_button", comment: "Edit Habit"))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                }
                .accessibilityLabel(NSLocalizedString("delete_habit_button", comment: "Delete Habit"))
            }
        }
        .sheet(isPresented: $showingEdit) {
            HabitCreateView(
                viewModel: HabitCreateViewModel(
                    name: viewModel.habit.name,
                    color: viewModel.habit.color.color,
                    iconName: viewModel.habit.iconName,
                    frequency: viewModel.habit.frequency,
                    customDays: viewModel.habit.customDays ?? [],
                    reminderTime: viewModel.habit.reminderTime
                ),
                onSave: { updated in
                    NotificationService.shared.cancelReminder(for: viewModel.habit)
                    if updated.reminderTime != nil {
                        NotificationService.shared.scheduleReminder(for: updated)
                    }
                    viewModel.updateHabit(updated)
                    showingEdit = false
                },
                onCancel: { showingEdit = false }
            )
        }
        .alert(NSLocalizedString("delete_habit_confirm_title", comment: "Delete Habit?"), isPresented: $showingDeleteAlert) {
            Button(NSLocalizedString("delete_button", comment: "Delete"), role: .destructive) {
                NotificationService.shared.cancelReminder(for: viewModel.habit)
                viewModel.deleteHabit()
            }
            Button(NSLocalizedString("cancel_button", comment: "Cancel"), role: .cancel) {}
        } message: {
            Text(NSLocalizedString("delete_habit_confirm_message", comment: "Are you sure you want to delete this habit?"))
        }
    }
}

// MARK: - CalendarGrid

struct CalendarGrid: View {
    @ObservedObject var viewModel: HabitDetailViewModel
    let days: Int
    private let calendar = Calendar.current
    
    var body: some View {
        let today = calendar.startOfDay(for: Date())
        let dates = (0..<days).map { calendar.date(byAdding: .day, value: -$0, to: today)! }.reversed()
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
            ForEach(dates, id: \.self) { date in
                let completed = viewModel.isCompleted(on: date)
                Button(action: { viewModel.toggleCompletion(on: date) }) {
                    Circle()
                        .fill(completed ? Color.green : Color(.systemGray5))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Text("\(calendar.component(.day, from: date))")
                                .font(.caption2)
                                .foregroundColor(completed ? .white : .primary)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(format: NSLocalizedString("calendar_day_accessibility_label", comment: "Day %d"), calendar.component(.day, from: date)))
                .accessibilityHint(completed ? NSLocalizedString("calendar_day_completed_hint", comment: "Completed") : NSLocalizedString("calendar_day_not_completed_hint", comment: "Not completed"))
            }
        }
    }
}

// MARK: - StatView

struct StatView: View {
    let label: String
    let value: String
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 60)
    }
} 