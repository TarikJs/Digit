//
//  HabitCreateView.swift
//  Digit
//
//  SwiftUI form for creating a new habit.
//

import SwiftUI

struct HabitCreateView: View {
    @ObservedObject var viewModel: HabitCreateViewModel
    var onSave: (Habit) -> Void
    var onCancel: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    // Example icon and color choices
    private let iconChoices = ["star.fill", "figure.run", "book.fill", "leaf.fill", "flame.fill", "heart.fill"]
    private let colorChoices: [Color] = [.accentColor, .blue, .orange, .green, .pink, .purple, .red, .yellow]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(NSLocalizedString("habit_name_label", comment: "Habit name label"))) {
                    TextField(NSLocalizedString("habit_name_placeholder", comment: "Habit name placeholder"), text: $viewModel.name)
                        .autocapitalization(.sentences)
                        .disableAutocorrection(false)
                }
                Section(header: Text(NSLocalizedString("habit_icon_label", comment: "Habit icon label"))) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(iconChoices, id: \.self) { icon in
                                Button(action: { viewModel.iconName = icon }) {
                                    Image(systemName: icon)
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .padding(8)
                                        .background(viewModel.iconName == icon ? Color.accentColor.opacity(0.2) : Color.clear)
                                        .clipShape(Circle())
                                        .accessibilityLabel(Text(icon))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                Section(header: Text(NSLocalizedString("habit_color_label", comment: "Habit color label"))) {
                    HStack(spacing: 16) {
                        ForEach(colorChoices, id: \.self) { color in
                            Button(action: { viewModel.color = color }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: viewModel.color == color ? 3 : 0)
                                    )
                                    .accessibilityLabel(Text("") /* Color names can be added for accessibility */)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                Section(header: Text(NSLocalizedString("habit_frequency_label", comment: "Habit frequency label"))) {
                    Picker(NSLocalizedString("habit_frequency_picker", comment: "Frequency"), selection: $viewModel.frequency) {
                        ForEach(Habit.Frequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue.capitalized).tag(freq)
                        }
                    }
                    .pickerStyle(.segmented)
                    if viewModel.frequency == .custom {
                        WeekdayPicker(selectedDays: $viewModel.customDays)
                    }
                }
                Section(header: Text(NSLocalizedString("reminder_label", comment: "Reminder label"))) {
                    Toggle(isOn: Binding(
                        get: { viewModel.reminderTime != nil },
                        set: { enabled in
                            if enabled {
                                // Default to 8:00 AM
                                viewModel.reminderTime = DateComponents(hour: 8, minute: 0)
                            } else {
                                viewModel.reminderTime = nil
                            }
                        }
                    )) {
                        Text(NSLocalizedString("enable_reminder_toggle", comment: "Enable reminder"))
                    }
                    if let reminderTime = viewModel.reminderTime {
                        DatePicker(
                            NSLocalizedString("reminder_time_picker", comment: "Reminder time"),
                            selection: Binding(
                                get: {
                                    let comps = reminderTime
                                    let calendar = Calendar.current
                                    return calendar.date(from: comps) ?? Date()
                                },
                                set: { date in
                                    let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                                    viewModel.reminderTime = comps
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("add_habit_title", comment: "Add Habit"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        onCancel()
                        dismiss()
                    }) {
                        Text(NSLocalizedString("cancel_button", comment: "Cancel"))
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        if let habit = viewModel.makeHabit() {
                            if habit.reminderTime != nil {
                                NotificationService.shared.scheduleReminder(for: habit)
                            }
                            onSave(habit)
                            dismiss()
                        }
                    }) {
                        Text(NSLocalizedString("save_button", comment: "Save"))
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}

// MARK: - WeekdayPicker

struct WeekdayPicker: View {
    @Binding var selectedDays: [Int]
    private let days = Calendar.current.shortWeekdaySymbols // ["Sun", "Mon", ...]
    
    var body: some View {
        HStack {
            ForEach(1...7, id: \.self) { day in
                let isSelected = selectedDays.contains(day)
                Button(action: {
                    if isSelected {
                        selectedDays.removeAll { $0 == day }
                    } else {
                        selectedDays.append(day)
                    }
                }) {
                    Text(days[day - 1])
                        .font(.caption)
                        .padding(8)
                        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
} 