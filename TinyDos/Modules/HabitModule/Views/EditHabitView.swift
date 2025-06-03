import SwiftUI
import Foundation

struct EditHabitView: View {
    @State var habit: Habit
    var onSave: (Habit) -> Void
    var onDelete: () -> Void
    var onCancel: () -> Void
    
    @State private var name: String
    @State private var description: String
    @State private var dailyGoal: Int
    @State private var icon: String
    @State private var startDate: Date
    @State private var endDate: Date?
    @State private var repeatFrequency: String
    @State private var weekdays: Set<Int>
    @State private var reminderTime: String?
    @State private var unit: String
    @State private var tag: String
    
    init(habit: Habit, onSave: @escaping (Habit) -> Void, onDelete: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.habit = habit
        self.onSave = onSave
        self.onDelete = onDelete
        self.onCancel = onCancel
        _name = State(initialValue: habit.name)
        _description = State(initialValue: habit.description ?? "")
        _dailyGoal = State(initialValue: habit.dailyGoal)
        _icon = State(initialValue: habit.icon)
        _startDate = State(initialValue: habit.startDate)
        _endDate = State(initialValue: habit.endDate)
        _repeatFrequency = State(initialValue: habit.repeatFrequency)
        _weekdays = State(initialValue: Set(habit.weekdays ?? []))
        _reminderTime = State(initialValue: habit.reminderTime)
        _unit = State(initialValue: habit.unit ?? "")
        _tag = State(initialValue: habit.tag ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Details")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    Stepper(value: $dailyGoal, in: 1...100) {
                        HStack {
                            Text("Goal: ")
                            Text("\(dailyGoal)")
                        }
                    }
                    TextField("Icon (SF Symbol)", text: $icon)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: Binding(get: { endDate ?? startDate }, set: { endDate = $0 }), displayedComponents: .date)
                    TextField("Repeat Frequency", text: $repeatFrequency)
                    WeekdayPicker(selectedWeekdays: $weekdays)
                    TextField("Reminder Time (HH:mm:ss)", text: Binding(get: { reminderTime ?? "" }, set: { reminderTime = $0 }))
                    TextField("Unit", text: $unit)
                    TextField("Tag", text: $tag)
                }
                Section {
                    Button("Save Changes") {
                        let updatedHabit = Habit(
                            id: habit.id,
                            userId: habit.userId,
                            name: name,
                            description: description.isEmpty ? nil : description,
                            dailyGoal: dailyGoal,
                            icon: icon,
                            startDate: startDate,
                            endDate: endDate,
                            repeatFrequency: repeatFrequency,
                            weekdays: weekdays.isEmpty ? nil : Array(weekdays),
                            reminderTime: reminderTime,
                            createdAt: habit.createdAt,
                            updatedAt: Date(),
                            unit: unit.isEmpty ? nil : unit,
                            tag: tag.isEmpty ? nil : tag
                        )
                        onSave(updatedHabit)
                    }
                    .foregroundColor(.blue)
                    Button("Delete Habit", role: .destructive) {
                        onDelete()
                    }
                }
            }
            .navigationBarTitle("Edit Habit", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") { onCancel() })
        }
    }
}

struct WeekdayPicker: View {
    @Binding var selectedWeekdays: Set<Int>
    let daySymbols = Calendar.current.shortWeekdaySymbols
    var body: some View {
        HStack {
            ForEach(1...7, id: \ .self) { weekday in
                let symbol = daySymbols[weekday - 1]
                Button(action: {
                    if selectedWeekdays.contains(weekday) {
                        selectedWeekdays.remove(weekday)
                    } else {
                        selectedWeekdays.insert(weekday)
                    }
                }) {
                    Text(symbol)
                        .padding(6)
                        .background(selectedWeekdays.contains(weekday) ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedWeekdays.contains(weekday) ? .white : .primary)
                        .cornerRadius(6)
                }
            }
        }
    }
} 