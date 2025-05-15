import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @Namespace private var segmentNamespace
    
    private let horizontalPadding: CGFloat = DigitLayout.Padding.horizontal
    
    // MARK: - Extracted: Header View
    private var headerView: some View {
        Text("See your activity for")
            .font(.digitTitle2)
            .fontWeight(.bold)
            .foregroundStyle(Color.digitBrand)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)
            .padding(.horizontal, horizontalPadding)
    }
    
    // MARK: - Extracted: Segmented Control
    private var segmentedControl: some View {
        HStack(spacing: 12) {
            ForEach(StatsViewModel.Period.allCases, id: \.self) { period in
                Button(action: { viewModel.selectedPeriod = period }) {
                    Text(period.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(viewModel.selectedPeriod == period ? Color.white : Color.digitBrand)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            ZStack {
                                if viewModel.selectedPeriod == period {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.digitBrand)
                                } else {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.digitBrand, lineWidth: 2)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 12)
    }
    
    // MARK: - Extracted: Date Picker Row
    private var datePickerRow: some View {
        HStack(spacing: 12) {
            Text(viewModel.periodTitle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.digitBrand)
            Spacer()
            HStack(spacing: 0) {
                Button(action: { viewModel.goToPreviousPeriod() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.digitBrand)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                Button(action: { viewModel.goToNextPeriod() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.digitBrand)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 12)
    }
    
    // MARK: - Extracted: Chart or Grid Section
    @ViewBuilder
    private var chartOrGridSection: some View {
        if viewModel.selectedPeriod == .week {
            WeeklyHabitGrid(habits: viewModel.weeklyHabits, days: viewModel.weekDays)
                .padding(.top, 8)
                .padding(.horizontal, horizontalPadding)
        } else {
            HabitAreaChartView(data: viewModel.chartData, range: .month)
                .padding(.top, 8)
                .padding(.horizontal, horizontalPadding)
        }
    }
    
    // MARK: - Extracted: Summary Cards Section
    private var summaryCardsSection: some View {
        ScrollView(showsIndicators: false) {
            if viewModel.summaryStats.isEmpty {
                VStack(spacing: 20) {
                    Image("asking-question")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .accessibilityLabel("No stats available")
                    Text("No stats yet")
                        .font(.digitHeadline)
                        .foregroundStyle(Color.digitBrand)
                    Text("Your stats will appear here once you start tracking habits.")
                        .font(.digitBody)
                        .foregroundStyle(Color.digitBrand)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, minHeight: 300)
                .padding(.top, 32)
            } else {
                VStack(spacing: 14) {
                    ForEach(viewModel.summaryStats) { stat in
                        HabitStatCard(stat: stat)
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 32)
            }
        }
    }
    
    // MARK: - Main Body
    var body: some View {
        ZStack {
            // Background removed to allow root background to show through
            VStack(spacing: 0) {
                segmentedControl // Extracted segmented control
                datePickerRow // Extracted date picker row
                chartOrGridSection // Extracted chart/grid section
                summaryCardsSection // Extracted summary cards
            }
            .background(Color.digitBackground)
        }
    }
}

// MARK: - Weekly Grid
struct WeeklyHabitGrid: View {
    let habits: [String]
    let days: [String]
    private let labelColumnWidth: CGFloat = 110
    // Day label row constants
    private let dayLabelWidth: CGFloat = 18
    private let dayLabelSpacing: CGFloat = 6
    // Squares grid constants
    private let squareSize: CGFloat = 18
    private let squareSpacing: CGFloat = 6
    private let squareCornerRadius: CGFloat = 5
    var body: some View {
        VStack(alignment: .leading, spacing: squareSpacing) {
            // Days header
            HStack(spacing: 0) {
                Spacer().frame(width: labelColumnWidth)
                Spacer()
                HStack(spacing: dayLabelSpacing) {
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundStyle(Color.digitBrand)
                            .frame(width: dayLabelWidth, alignment: .center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
            }
            ForEach(habits, id: \.self) { habit in
                HStack(spacing: 0) {
                    Text(habit)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.digitBrand)
                        .frame(width: labelColumnWidth, alignment: .leading)
                        .frame(height: squareSize, alignment: .center)
                    Spacer()
                    HStack(spacing: squareSpacing) {
                        ForEach(0..<7) { _ in
                            RoundedRectangle(cornerRadius: squareCornerRadius)
                                .stroke(Color.digitBrand, lineWidth: 0.8)
                                .background(RoundedRectangle(cornerRadius: squareCornerRadius).fill(Color.digitHabitGreen.opacity(0.7)))
                                .frame(width: squareSize, height: squareSize)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.digitBackground)
        .cornerRadius(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Habit Stat Card
struct HabitStatCard: View {
    let stat: HabitStat
    var body: some View {
        HStack {
            Image(systemName: stat.icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.digitBrand)
            Text(stat.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.digitBrand)
            Spacer()
            Text(stat.value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.digitBrand)
        }
        .padding(16)
        .background(stat.color)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.digitBrand, lineWidth: 1.2)
        )
        .cornerRadius(16)
    }
}

#Preview {
    StatsView()
} 

