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
    private let iconChoices = [
        "star.fill", "figure.run", "book.fill", "leaf.fill", "flame.fill", "heart.fill", "pencil", "bed.double.fill", "sun.max.fill", "moon.fill"
    ]
    private let colorChoices: [Color] = [.accentColor, .blue, .orange, .green, .pink, .purple, .red, .yellow]
    private let alertTimes: [HabitCreateViewModel.AlertTime] = [
        .init(minutesBefore: 0), .init(minutesBefore: 5), .init(minutesBefore: 10), .init(minutesBefore: 30), .init(minutesBefore: 60)
    ]
    
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    // MARK: - Quit/Build Segmented Control
                    OutlinedCard {
                        OutlinedSegmentedControl(
                            options: ["Quit habit", "Build habit"],
                            selectedIndex: Binding(
                                get: { viewModel.mode == .build ? 1 : 0 },
                                set: { viewModel.mode = $0 == 1 ? .build : .quit }
                            )
                        )
                    }
                    // MARK: - Name & Description
                    OutlinedCard {
                        VStack(spacing: 8) {
                            OutlinedTextField(text: $viewModel.name, placeholder: "Name")
                            OutlinedTextField(text: $viewModel.description, placeholder: "Description")
                        }
                    }
                    // MARK: - Category
                    OutlinedCard {
                        HStack(spacing: 12) {
                            OutlinedCategoryButton(
                                title: "Body health",
                                icon: "figure.run",
                                isSelected: viewModel.category == .body,
                                accentColor: .accentLime,
                                action: { viewModel.category = .body }
                            )
                            OutlinedCategoryButton(
                                title: "Mind health",
                                icon: "brain.head.profile",
                                isSelected: viewModel.category == .mind,
                                accentColor: .accentPurple,
                                action: { viewModel.category = .mind }
                            )
                        }
                    }
                    // MARK: - Goal per day
                    OutlinedCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Goal per day")
                                    .font(.headline)
                                    .foregroundColor(.brandBlue)
                                Spacer()
                                Toggle("", isOn: $viewModel.hasGoal)
                                    .labelsHidden()
                                    .tint(.brandBlue)
                            }
                            if viewModel.hasGoal {
                                OutlinedTextField(text: $viewModel.goalText, placeholder: "85 pages per day")
                            }
                        }
                    }
                    // MARK: - Date, Repeat, Alerts
                    OutlinedCard {
                        VStack(spacing: 10) {
                            HStack {
                                Text("Start day").foregroundColor(.brandBlue)
                                Spacer()
                                Text(viewModel.startDate, style: .date)
                                    .foregroundColor(.brandBlue)
                            }
                            HStack {
                                Text("End day").foregroundColor(.brandBlue)
                                Spacer()
                                Text(viewModel.endDate, style: .date)
                                    .foregroundColor(.brandBlue.opacity(0.6))
                            }
                            HStack {
                                Text("Repeats").foregroundColor(.brandBlue)
                                Spacer()
                                Text(viewModel.repeatType.rawValue.capitalized)
                                    .foregroundColor(.brandBlue)
                            }
                            HStack {
                                Text("Every").foregroundColor(.brandBlue)
                                Spacer()
                                Text("\(viewModel.repeatEvery) week")
                                    .foregroundColor(.brandBlue)
                            }
                            HStack(spacing: 6) {
                                ForEach(1...7, id: \.self) { day in
                                    let isSelected = viewModel.customDays.contains(day)
                                    Button(action: {
                                        if isSelected {
                                            viewModel.customDays.removeAll { $0 == day }
                                        } else {
                                            viewModel.customDays.append(day)
                                        }
                                    }) {
                                        Text(weekdaySymbols[day - 1])
                                            .font(.headline)
                                            .frame(width: 32, height: 32)
                                            .background(isSelected ? Color.brandBlue : Color.clear)
                                            .foregroundColor(isSelected ? .white : .brandBlue)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.brandBlue, lineWidth: 2)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            HStack {
                                Text("Alerts").foregroundColor(.brandBlue)
                                Spacer()
                                Picker("Alert time", selection: $viewModel.alertTime) {
                                    ForEach(alertTimes) { alert in
                                        Text(alert.description).tag(alert)
                                    }
                                }
                                .pickerStyle(.menu)
                                .foregroundColor(.brandBlue)
                            }
                        }
                    }
                    // MARK: - Icon Search & Picker
                    OutlinedCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.brandBlue)
                                TextField("Search icon", text: $viewModel.iconSearchText)
                                    .textFieldStyle(.plain)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                Spacer()
                                Button(action: { /* TODO: Add voice search */ }) {
                                    Image(systemName: "mic.fill")
                                        .foregroundColor(.brandBlue)
                                }
                                .accessibilityLabel("Voice search")
                            }
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(iconChoices.filter { viewModel.iconSearchText.isEmpty ? true : $0.localizedCaseInsensitiveContains(viewModel.iconSearchText) }, id: \.self) { icon in
                                        OutlinedIconButton(
                                            icon: icon,
                                            isSelected: viewModel.iconName == icon,
                                            fillColor: .accentLime,
                                            action: { viewModel.iconName = icon }
                                        )
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 8)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("New habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        onCancel()
                        dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundColor(.brandBlue)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("New habit")
                        .font(.headline)
                        .foregroundColor(.brandBlue)
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
                        Text("Add")
                            .foregroundColor(.brandBlue)
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}

#if DEBUG
struct HabitCreateView_Previews: PreviewProvider {
    static var previews: some View {
        HabitCreateView(
            viewModel: HabitCreateViewModel(),
            onSave: { _ in },
            onCancel: {}
        )
    }
}
#endif 