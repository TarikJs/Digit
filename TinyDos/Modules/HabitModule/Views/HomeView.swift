import SwiftUI

struct HomeView: View {
    var onHabitCompleted: () -> Void = {}
    @ObservedObject var viewModel: HomeViewModel
    @Binding var isEditMode: Bool
    var headerPlusAction: () -> Void = {}
    @State private var progressCurrentPage: Int = 0
    private let globalMaxWidth: CGFloat = 500
    @State private var isSectionExpanded: Bool = true
    // Tag state is now passed in
    var customTags: [String]
    var setCustomTags: ([String]) -> Void
    @State private var isAddTagSheetPresented: Bool = false
    @State private var newTagName: String = ""
    // --- Tag creation state ---
    // --- Edit Habit State ---
    @State private var selectedHabitForEdit: Habit? = nil
    @State private var isEditHabitSheetPresented: Bool = false
    // ---
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "F5F6F7")
                .ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Section header
                        Text("Habits")
                            .font(.plusJakartaSans(size: 24, weight: .bold))
                            .foregroundStyle(Color.digitBrand)
                            .padding(.top, DigitLayout.Spacing.xl)
                            .padding(.horizontal, 16)
                            .padding(.bottom, DigitLayout.Spacing.medium)
                        // Filter/tag bar
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DigitLayout.Spacing.medium) {
                                // ADD TAG button (now first)
                                Button(action: { isAddTagSheetPresented = true }) {
                                    HStack(spacing: DigitLayout.Spacing.xs) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 14, weight: .bold))
                                        Text("ADD TAG")
                                            .font(.plusJakartaSans(size: 14, weight: .semibold))
                                    }
                                    .foregroundStyle(Color.digitSecondaryText)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.digitSecondaryText, lineWidth: 1.2)
                                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.clear))
                                    )
                                }
                                .accessibilityLabel("Add tag")
                                // ALL tag (selected example)
                                Button(action: { /* TODO: Filter ALL */ }) {
                                    Text("ALL")
                                        .font(.plusJakartaSans(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.white)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 12)
                                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.digitBrand))
                                }
                                .accessibilityLabel("Show all habits")
                                // Custom tags
                                ForEach(customTags, id: \ .self) { tag in
                                    Button(action: { /* TODO: Filter by tag */ }) {
                                        Text(tag)
                                            .font(.plusJakartaSans(size: 14, weight: .semibold))
                                            .foregroundStyle(Color.digitSecondaryText)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color.digitSecondaryText, lineWidth: 1.2)
                                                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.clear))
                                            )
                                    }
                                    .accessibilityLabel("Show habits for tag \(tag)")
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, DigitLayout.Spacing.large)
                        }
                        .sheet(isPresented: $isAddTagSheetPresented) {
                            VStack(spacing: 24) {
                                Text("Create New Tag")
                                    .font(.plusJakartaSans(size: 20, weight: .bold))
                                    .padding(.top, 32)
                                TextField("Tag name", text: $newTagName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal, 24)
                                HStack(spacing: 16) {
                                    Button("Cancel") {
                                        isAddTagSheetPresented = false
                                        newTagName = ""
                                    }
                                    .foregroundStyle(Color.digitSecondaryText)
                                    Spacer()
                                    Button("Save") {
                                        let trimmed = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
                                        if !trimmed.isEmpty && !customTags.contains(trimmed) {
                                            setCustomTags(customTags + [trimmed])
                                        }
                                        isAddTagSheetPresented = false
                                        newTagName = ""
                                    }
                                    .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                    .foregroundStyle(Color.digitBrand)
                                }
                                .padding(.horizontal, 24)
                                Spacer()
                            }
                            .presentationDetents([.medium])
                        }
                        // Section group (example: Self-Development)
                        if !customTags.isEmpty {
                            HStack {
                                Text("CATEGORY") // Placeholder, can be dynamic later
                                    .font(.plusJakartaSans(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.digitSecondaryText)
                                Spacer()
                                Button(action: { isSectionExpanded.toggle() }) {
                                    Image(systemName: "chevron.down")
                                        .rotationEffect(.degrees(isSectionExpanded ? 0 : -90))
                                        .foregroundColor(Color.digitSecondaryText)
                                        .font(.system(size: 14, weight: .semibold))
                                        .padding(.trailing, 2)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, DigitLayout.Spacing.small)
                        }
                        if viewModel.activeHabits(on: viewModel.selectedDate).isEmpty {
                            VStack(spacing: DigitLayout.Spacing.xl) {
                                Image("Zero Tasks 3")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 220)
                                    .accessibilityLabel("No habits illustration")
                                    .padding(.top, 32)
                                Text("No habits yet")
                                    .font(.plusJakartaSans(size: 22, weight: .bold))
                                    .foregroundStyle(Color.digitBrand)
                                Text("Start your journey by creating your first habit. Building small routines leads to big results!")
                                    .font(.plusJakartaSans(size: 16, weight: .regular))
                                    .foregroundStyle(Color.digitSecondaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                        } else if isSectionExpanded {
                            VStack(spacing: DigitLayout.Spacing.large) {
                                ForEach(viewModel.activeHabits(on: viewModel.selectedDate)) { habit in
                                    HStack(spacing: 0) {
                                        // Icon with green ring
                                        ZStack {
                                            Circle()
                                                .stroke(Color.digitTabBarGreen, lineWidth: 5)
                                                .frame(width: 48, height: 48)
                                            Image(systemName: habit.icon)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 28, height: 28)
                                                .foregroundStyle(Color.digitTabBarGreen)
                                        }
                                        .padding(.leading, 16)
                                        // Title and subtitle
                                        VStack(alignment: .leading, spacing: DigitLayout.Spacing.xs) {
                                            Text(habit.name)
                                                .font(.plusJakartaSans(size: 18, weight: .semibold))
                                                .foregroundStyle(Color.digitBrand)
                                            Text("2 times a day") // TODO: Replace with real frequency
                                                .font(.plusJakartaSans(size: 14, weight: .regular))
                                                .foregroundStyle(Color.digitSecondaryText)
                                        }
                                        .padding(.leading, DigitLayout.Spacing.medium)
                                        Spacer()
                                        // Plus button
                                        Button(action: { viewModel.incrementProgress(for: habit, on: viewModel.selectedDate) }) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: DigitLayout.cornerRadius, style: .continuous)
                                                    .stroke(Color.digitBrand, lineWidth: 2)
                                                    .background(RoundedRectangle(cornerRadius: DigitLayout.cornerRadius).fill(Color.white))
                                                Image(systemName: "plus")
                                                    .font(.system(size: 22, weight: .bold))
                                                    .foregroundStyle(Color.digitBrand)
                                            }
                                            .frame(width: 44, height: 44)
                                        }
                                        .padding(.trailing, 16)
                                    }
                                    .frame(height: 72)
                                    .background(Color.white)
                                    .cornerRadius(DigitLayout.cornerRadius)
                                    .shadow(color: Color.black.opacity(0.03), radius: 2, y: 1)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, DigitLayout.Spacing.xxl)
                        }
                    }
                    .padding(.top, 0)
                    .frame(maxWidth: globalMaxWidth)
                    .padding(.bottom, 0)
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            viewModel.onHabitCompleted = onHabitCompleted
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $isEditHabitSheetPresented) {
            if let habit = selectedHabitForEdit {
                EditHabitView(
                    habit: habit,
                    onSave: { updatedHabit in
                        viewModel.updateHabit(updatedHabit)
                        isEditHabitSheetPresented = false
                    },
                    onDelete: {
                        viewModel.deleteHabit(habit)
                        isEditHabitSheetPresented = false
                    },
                    onCancel: {
                        isEditHabitSheetPresented = false
                    }
                )
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private var calendarStrip: some View {
        HStack(spacing: 16) {
            ForEach(-3...3, id: \ .self) { offset in
                let date = Calendar.current.date(byAdding: .day, value: offset, to: viewModel.selectedDate) ?? viewModel.selectedDate
                let isSelected = Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                let isToday = Calendar.current.isDateInToday(date)
                let completed = viewModel.completedHabitsCount(on: date)
                let total = viewModel.activeHabits(on: date).count
                let textColor: Color = isToday ? Color.digitTabBarGreen : (isSelected ? Color.digitBrand : Color.digitSecondaryText)
                VStack(spacing: DigitLayout.Spacing.xs) {
                    Text(dayNumber(from: date))
                        .font(.plusJakartaSans(size: 18, weight: .semibold))
                        .foregroundStyle(textColor)
                    Text(dayShortName(from: date))
                        .font(.plusJakartaSans(size: 12, weight: .medium))
                        .foregroundStyle(textColor)
                    Text("\(completed)/\(total)")
                        .font(.plusJakartaSans(size: 11, weight: .medium))
                        .foregroundStyle(textColor)
                    Rectangle()
                        .fill(isToday ? Color.digitTabBarGreen : (isSelected ? Color.digitBrand : Color.clear))
                        .frame(height: 3)
                        .cornerRadius(1.5)
                        .padding(.top, DigitLayout.Spacing.xs)
                }
                .frame(width: 44, height: 60)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        viewModel.selectedDate = date
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

    // MARK: - Split out HabitGoalCards for type-checking
    private func isDateToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(calendar.startOfDay(for: date), inSameDayAs: calendar.startOfDay(for: Date()))
    }

    private var habitGoalCards: some View {
        let isToday = isDateToday(viewModel.selectedDate)
        return ForEach(viewModel.activeHabits(on: viewModel.selectedDate)) { habit in
            HabitGoalCard(
                icon: habit.icon,
                title: habit.name,
                progress: viewModel.progress(for: habit, on: viewModel.selectedDate),
                goal: viewModel.goal(for: habit, on: viewModel.selectedDate),
                unit: habit.unit,
                tag: habit.tag,
                onIncrement: { viewModel.incrementProgress(for: habit, on: viewModel.selectedDate) },
                onDecrement: { viewModel.decrementProgress(for: habit, on: viewModel.selectedDate) },
                buttonsEnabled: isToday && !viewModel.isUpdatingProgress(for: habit, on: viewModel.selectedDate),
                isEditMode: isEditMode,
                onDelete: isEditMode ? { viewModel.deleteHabit(habit) } : nil,
                onTap: {
                    selectedHabitForEdit = habit
                    isEditHabitSheetPresented = true
                }
            )
            .id(habit.id)
            .padding(.vertical, 2)
        }
    }
}

struct HabitRow: View {
    let icon: String
    let title: String
    let isCompleted: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.digitBrand)
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.digitBrand)
            Spacer()
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.digitBrand, lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(isCompleted ? Color.digitBrand : Color.digitBackground)
                        )
                        .frame(width: 28, height: 28)
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(color)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.digitBrand, lineWidth: 1.2)
        )
        .cornerRadius(16)
        .padding(.vertical, 2)
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(habitRepository: HabitRepository(), progressRepository: ProgressRepository(), userId: UUID()), isEditMode: .constant(false), customTags: [], setCustomTags: { _ in })
}

// MARK: - Progress Card Data
private struct ProgressCardData: Identifiable {
    var id: String { title }
    let icon: String
    let title: String
    let progress: String
    let goal: String
    let unit: String
    let color: Color
}

// Helper for sticky header background
struct StickyHeaderHelper: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: OffsetKey.self, value: geometry.frame(in: .named("scroll")).minY)
        }
    }
}

private struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
