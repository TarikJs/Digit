import SwiftUI

public struct HabitHomeHeaderView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var selectedDate: Date
    let onPlusTap: () -> Void

    init(viewModel: HomeViewModel, selectedDate: Binding<Date>, onPlusTap: @escaping () -> Void) {
        self.viewModel = viewModel
        self._selectedDate = selectedDate
        self.onPlusTap = onPlusTap
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top row: Today + date, plus button
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundStyle(Color.primary)
                        .accessibilityAddTraits(.isHeader)
                    Text(formattedDate(selectedDate))
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundStyle(Color.digitSecondaryText)
                        .accessibilityLabel(formattedDateAccessibility(selectedDate))
                }
                Spacer()
                Button(action: onPlusTap) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.digitTabBarGreen)
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                    .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Add Habit")
                .buttonStyle(.plain)
            }
            .padding(.top, 24)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            // Calendar strip
            calendarStrip
                .padding(.top, 24)
                .padding(.horizontal, 16)
                .padding(.bottom, 0)

            // Thin green line under calendar
            Rectangle()
                .fill(Color.digitTabBarGreen)
                .frame(height: 2)
                .padding(.horizontal, 0)
                .padding(.top, 4)
        }
        .background(Color.digitBackground.ignoresSafeArea(edges: .top))
    }

    private var calendarStrip: some View {
        HStack(spacing: 0) {
            ForEach(-3...3, id: \ .self) { offset in
                let date = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) ?? selectedDate
                let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                let isToday = Calendar.current.isDateInToday(date)
                let completed = viewModel.completedHabitsCount(on: date)
                let total = viewModel.activeHabits(on: date).count
                let textColor: Color = isToday ? Color.digitTabBarGreen : (isSelected ? Color.digitBrand : Color.digitSecondaryText)
                VStack(spacing: 2) {
                    Text(dayNumber(from: date))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(textColor)
                    Text(dayShortName(from: date))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(textColor)
                    Text("\(completed)/\(total)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(textColor)
                    // Underline for selected day or today
                    Rectangle()
                        .fill(isToday ? Color.digitTabBarGreen : (isSelected ? Color.digitBrand : Color.clear))
                        .frame(height: 3)
                        .cornerRadius(1.5)
                        .padding(.top, 2)
                }
                .frame(width: 48, height: 60)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selectedDate = date
                        viewModel.selectDate(date)
                    }
                }
                .accessibilityElement()
                .accessibilityLabel("\(dayShortName(from: date)), \(completed) completed out of \(total)")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private func formattedDateAccessibility(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
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
    let vm = HomeViewModel(habitRepository: HabitRepository(), progressRepository: ProgressRepository(), userId: UUID())
    return HabitHomeHeaderView(viewModel: vm, selectedDate: .constant(Date())) {
        // Placeholder for onPlusTap
    }
    .background(Color.gray.opacity(0.2))
}
#endif 