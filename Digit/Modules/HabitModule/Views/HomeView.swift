import SwiftUI

struct HomeView: View {
    var onHabitCompleted: () -> Void = {}
    @ObservedObject var viewModel: HomeViewModel
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

                // Header separator
                Divider()
                    .background(Color.digitDivider)
                    .padding(.bottom, 4)
                
                // MARK: - Calendar (Date Selector)
                dateSelector
                    .padding(.top, 8)
                    .padding(.horizontal, Layout.horizontalPadding)
                    .padding(.bottom, 11)
                
                // Divider between calendar and gray section
                Divider()
                    .background(Color.digitDivider)
                
                // Gray section starts immediately after divider
                ZStack(alignment: .top) {
                    // Sticky header
                    Color.digitGrayLight
                        .frame(height: 48)
                        .shadow(color: Color.black.opacity(0.03), radius: 2, y: 2)
                        .overlay(
                            Text("Your Goals")
                                .font(.digitTitle2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.digitBrand)
                                .padding(.top, 12)
                                .padding(.bottom, 8)
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
            }
            .background(Color.digitBackground)
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
    }
    
    private var dateSelector: some View {
        HStack(spacing: 6) {
            ForEach(-3...3, id: \ .self) { offset in
                let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
                let isSelected = Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                VStack(spacing: 2) {
                    Text(dayNumber(from: date))
                        .font(.system(size: 16, weight: .semibold))
                    Text(dayName(from: date))
                        .font(.system(size: 12))
                    Text("5/10")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(isSelected ? Color.white : Color.digitBrand)
                }
                .frame(width: 48, height: 60)
                .contentShape(Rectangle())
                .foregroundStyle(isSelected ? Color.white : Color.digitBrand)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.digitBrand : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.digitBrand, lineWidth: isSelected ? 2 : 1)
                )
                .onTapGesture {
                    viewModel.selectDate(date)
                }
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
    private var habitGoalCards: some View {
        ForEach(viewModel.habits) { habit in
            HStack(spacing: 12) {
                Image(systemName: habit.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.digitBrand)
                Text(habit.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.digitBrand)
                Spacer()
            }
            .padding(16)
            .background(Color.digitBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.digitBrand, lineWidth: 1.2)
            )
            .cornerRadius(16)
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
    HomeView(viewModel: HomeViewModel(habitService: HabitService()))
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
