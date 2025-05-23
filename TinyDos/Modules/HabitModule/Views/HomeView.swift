import SwiftUI

struct HomeView: View {
    var onHabitCompleted: () -> Void = {}
    @ObservedObject var viewModel: HomeViewModel
    @Binding var isEditMode: Bool
    @State private var progressCurrentPage: Int = 0
    private let progressCards: [ProgressCardData] = [
        .init(icon: "drop.fill", title: "Drink water", progress: "1", goal: "10", unit: "glasses", color: .digitHabitGreen),
        .init(icon: "book.fill", title: "Read book", progress: "0", goal: "30", unit: "pages", color: .digitHabitPurple),
        .init(icon: "bed.double.fill", title: "Sleep early", progress: "0", goal: "1", unit: "night", color: .digitHabitGreen),
        .init(icon: "figure.walk", title: "Walk", progress: "0", goal: "5000", unit: "steps", color: .digitHabitGreen),
        .init(icon: "flame.fill", title: "Burn calories", progress: "0", goal: "500", unit: "kcal", color: .digitHabitPurple),
        .init(icon: "heart.fill", title: "Self care", progress: "0", goal: "1", unit: "activity", color: .digitHabitPurple)
    ]
    private var progressCardPairs: [[ProgressCardData]] {
        stride(from: 0, to: progressCards.count, by: 2).map { i in
            Array(progressCards[i..<min(i+2, progressCards.count)])
        }
    }
    
    // Global max width for all content
    private let globalMaxWidth: CGFloat = 500

    // MARK: - Layout Constants
    private enum Layout {
        static let horizontalPadding: CGFloat = 16 // General horizontal margin for all sections

        // General Section Title Spacing
        static let sectionTitleTopPadding: CGFloat = 24
        static let sectionTitleBottomPadding: CGFloat = 8

        // Header Section
        static let headerTopPadding: CGFloat = 2
        static let headerBottomPadding: CGFloat = 8

        // Calendar Section
        static let calendarTopPadding: CGFloat = 16
        static let calendarBottomPadding: CGFloat = 16

        // Daily Progress Section
        static let progressTitleTopPadding: CGFloat = 20
        static let progressCarouselTopPadding: CGFloat = -6
        static let progressCarouselBottomPadding: CGFloat = 0
        static let progressDotTopPadding: CGFloat = 4

        // Daily Completions Section
        static let completionsTitleTopPadding: CGFloat = 6
        static let completionsListTopPadding: CGFloat = -6

        static let sectionSpacing: CGFloat = 0 // spacing between section title and next section
    }
    
    var body: some View {
        ZStack {
            // Background removed to allow root background to show through
            
            VStack(spacing: 0) {
                // MARK: - Header (Today/title row)
                // Insert header here if not already present

                // Gray section with sticky header and scrollable content
                ZStack(alignment: .top) {
                    Color.digitGrayLight
                        .ignoresSafeArea()
                    // Sticky header
                    Color.digitBrand
                        .frame(height: 48)
                        .shadow(color: Color.black.opacity(0.03), radius: 2, y: 2)
                        .overlay(
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.digitAccentRed)
                                    .frame(width: 4, height: 24)
                                Text("Your Goals")
                                    .font(.plusJakartaSans(size: 22, weight: .bold))
                                    .foregroundStyle(Color.white)
                                    .accessibilityAddTraits(.isHeader)
                                    .accessibilityLabel("Your Goals")
                                Spacer()
                            }
                            .padding(.horizontal, DigitLayout.Padding.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        )
                        .overlay(
                            Divider()
                                .background(Color.digitDivider), alignment: .bottom
                        )
                        .zIndex(1)

                    // Scrollable content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            // Spacer to prevent overlap with sticky header
                            Color.clear.frame(height: 48)
                            // MARK: - Habit List
                            VStack(spacing: 12) {
                                if viewModel.habits.isEmpty {
                                    VStack(spacing: 12) {
                                        Spacer(minLength: 32)
                                        Image("asking-question")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 120, height: 120)
                                            .accessibilityLabel("No habits yet")
                                        Text("No habits yet. Add your first habit!")
                                            .font(.digitBody)
                                            .foregroundStyle(Color.digitBrand.opacity(0.7))
                                            .multilineTextAlignment(.center)
                                        Spacer(minLength: 32)
                                    }
                                    .frame(maxWidth: .infinity)
                                } else {
                                    habitGoalCards
                                }
                            }
                            .padding(.top, 8)
                        }
                        .frame(maxWidth: globalMaxWidth)
                        .padding(.top, Layout.completionsListTopPadding)
                        .padding(.horizontal, DigitLayout.Padding.horizontal)
                        .padding(.bottom, 16)
                    }
                }
                .background(Color.digitGrayLight)

                // MARK: - Calendar (Date Selector) at the bottom
                Divider()
                    .background(Color.digitDivider)
                dateSelector
                    .padding(.top, 8)
                    .padding(.horizontal, Layout.horizontalPadding)
                    .padding(.bottom, 11)
            }
            .background(Color.digitBackground)

            // Floating pencil/checkmark button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) { isEditMode.toggle() }
                    }) {
                        Image(systemName: isEditMode ? "checkmark" : "trash.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.white)
                            .frame(width: 44, height: 44)
                            .background(Color.digitAccentRed)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .shadow(color: Color.black.opacity(0.08), radius: 2, y: 1)
                            .accessibilityLabel(isEditMode ? "Done editing" : "Edit habits")
                    }
                    .padding(.trailing, DigitLayout.Padding.horizontal)
                    .padding(.bottom, 96)
                }
            }
        }
        .preferredColorScheme(.light)
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
    }
    
    private var dateSelector: some View {
        HStack(spacing: 6) {
            ForEach(-3...3, id: \ .self) { offset in
                let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
                let isSelected = Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                let isToday = Calendar.current.isDateInToday(date)
                let completed = viewModel.completedHabitsCount(on: date)
                let total = viewModel.activeHabits(on: date).count
                let textColor: Color = isToday ? Color.digitAccentRed : (isSelected ? Color.digitBrand : Color.digitSecondaryText)
                VStack(spacing: 2) {
                    Text(dayNumber(from: date))
                        .font(.plusJakartaSans(size: 16, weight: .semibold))
                        .foregroundStyle(textColor)
                    Text(dayName(from: date))
                        .font(.plusJakartaSans(size: 12))
                        .foregroundStyle(textColor)
                    Text("\(completed)/\(total)")
                        .font(.plusJakartaSans(size: 11, weight: .medium))
                        .foregroundStyle(textColor)
                    // Underline for selected day or today
                    Rectangle()
                        .fill(isToday ? Color.digitAccentRed : (isSelected ? Color.digitBrand : Color.clear))
                        .frame(height: 3)
                        .cornerRadius(1.5)
                        .padding(.top, 2)
                }
                .frame(width: 48, height: 60)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.selectDate(date)
                }
                .accessibilityElement()
                .accessibilityLabel("\(dayName(from: date)), \(completed) completed out of \(total)")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func dayNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
    private func dayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
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
                onIncrement: { viewModel.incrementProgress(for: habit, on: viewModel.selectedDate) },
                onDecrement: { viewModel.decrementProgress(for: habit, on: viewModel.selectedDate) },
                buttonsEnabled: isToday && !viewModel.isUpdatingProgress(for: habit, on: viewModel.selectedDate),
                isEditMode: isEditMode,
                onDelete: isEditMode ? { viewModel.deleteHabit(habit) } : nil
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
    HomeView(viewModel: HomeViewModel(habitRepository: HabitRepository(), progressRepository: ProgressRepository(), userId: UUID()), isEditMode: .constant(false))
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
