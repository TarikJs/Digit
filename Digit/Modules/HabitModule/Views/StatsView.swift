import SwiftUI
import Charts

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
        CompletionBarChartCard(data: [
            .init(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, percent: 1.0),
            .init(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, percent: 1.0),
            .init(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, percent: 0.0),
            .init(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, percent: 1.0),
            .init(date: Date(), percent: 0.5)
        ])
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
    
    // MARK: - Period Menu Dropdown (Large Title Style)
    private var periodMenu: some View {
        Menu {
            ForEach(StatsViewModel.Period.allCases, id: \ .self) { period in
                Button {
                    viewModel.selectedPeriod = period
                } label: {
                    Text(period.title)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(viewModel.selectedPeriod.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)
            .padding(.bottom, 12)
            .padding(.horizontal, horizontalPadding)
        }
    }
    
    // MARK: - Main Body
    var body: some View {
        ZStack {
            Color.digitGrayLight
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                    periodMenu
                    chartOrGridSection
                    HabitSummaryRow(perfect: 2, partial: 1, missed: 2)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    // 3-Month Habit Cards Section (mock data)
                    VStack(spacing: 16) {
                        HabitCalendarCard(habit: .mock1)
                        HabitCalendarCard(habit: .mock2)
            }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
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

// MARK: - New Bar Chart Card (Production Style)
private struct CompletionBarChartCard: View {
    struct DayStat: Identifiable {
        let id = UUID()
        let date: Date
        let percent: Double // 0.0...1.0
    }
    let data: [DayStat]
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("AVG COMPLETION RATE")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.top, 16)
                .padding(.horizontal, 16)
            Text("50%") // TODO: Calculate from data
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            Chart(data) {
                BarMark(
                    x: .value("Date", $0.date, unit: .day),
                    y: .value("Completion", $0.percent)
                )
                .foregroundStyle(Color.digitBrand)
                .cornerRadius(4)
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: Array(stride(from: 0.0, through: 1.0, by: 0.1))) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [2]))
                        .foregroundStyle(Color.digitDivider)
                    AxisTick()
                        .foregroundStyle(Color.digitDivider)
                    AxisValueLabel() {
                        if let percent = value.as(Double.self) {
                            Text("\(Int(percent * 100))%")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel() {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.month(.abbreviated).day())
                                .foregroundColor(.secondary)
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                }
            }
            .frame(height: 320)
            .padding(.top, 16)
            .padding(.horizontal, 8)
            .background(Color.digitBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
        }
        .background(Color.digitBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.digitBrand, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Habit Summary Row
private struct HabitSummaryRow: View {
    let perfect: Int
    let partial: Int
    let missed: Int

    private let cornerRadius: CGFloat = 16

    var body: some View {
        HStack(spacing: 0) {
            summaryCell(icon: "circle.fill", iconColor: .blue, label: "PERFECT", value: perfect)
            shortDivider
            summaryCell(icon: "circle.lefthalf.filled", iconColor: .orange, label: "PARTIAL", value: partial)
            shortDivider
            summaryCell(icon: "xmark.circle.fill", iconColor: .red, label: "MISSED", value: missed)
        }
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.digitBrand, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    private var shortDivider: some View {
        VStack {
            Spacer()
            Rectangle()
                .fill(Color.digitBrand.opacity(0.15))
                .frame(width: 1, height: 36)
            Spacer()
        }
    }

    private func summaryCell(icon: String, iconColor: Color, label: String, value: Int) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(iconColor)
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.digitBrand)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Mock Data Types for HabitCalendarCard
private struct MockDayCompletion: Identifiable {
    let id = UUID()
    let date: Date
    let progress: Int
    let goal: Int
    let isActive: Bool
}

private struct MockHabitCalendarData: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let percentCompleted: Int
    let days: [MockDayCompletion]
    static let mock1 = MockHabitCalendarData(
        icon: "flame.fill",
        title: "Exercise",
        percentCompleted: 80,
        days: (0..<90).map { i in
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            return MockDayCompletion(date: date, progress: Int.random(in: 0...1), goal: 1, isActive: true)
        }
    )
    static let mock2 = MockHabitCalendarData(
        icon: "book.fill",
        title: "Read",
        percentCompleted: 60,
        days: (0..<90).map { i in
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            return MockDayCompletion(date: date, progress: Int.random(in: 0...1), goal: 1, isActive: true)
        }
    )
}

// MARK: - HabitCalendarCard and Dependencies (Copied)
private struct HabitCalendarCard: View {
    let habit: MockHabitCalendarData
    private let cardHeight: CGFloat = 280
    @State private var showInfoAlert = false
    private var percentCompletedText: String {
        "\(habit.percentCompleted)% completed"
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: habit.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.digitBrand)
                Text(habit.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.digitBrand)
                Spacer()
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showInfoAlert = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color.digitBrand.opacity(0.7))
                        .padding(.trailing, 2)
                }
                .accessibilityLabel("Info about this card")
            }
            .padding(.top, 20)
            .padding(.horizontal, 16)
            Divider()
                .background(Color.digitDivider)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            ZStack(alignment: .topLeading) {
                HabitCalendarGrid(days: habit.days)
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 24)
            .frame(maxHeight: .infinity)
            Divider()
                .background(Color.digitDivider)
                .padding(.top, 16)
                .padding(.horizontal, 16)
            HStack(alignment: .center) {
                Text(percentCompletedText)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.digitBrand)
                Spacer()
                HabitGridLegend()
                    .scaleEffect(0.95)
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .frame(height: cardHeight)
        .background(Color.digitBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.digitBrand, lineWidth: 1)
        )
        .padding(.vertical, 6)
        .alert(isPresented: $showInfoAlert) {
            Alert(
                title: Text("What does this card show?"),
                message: Text("This card shows your habit completion over the last 90 days. Each square represents a day, colored by how much you completed your goal. The percentage at the bottom is the total completion rate for this habit over the last 90 days."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

private struct HabitCalendarGrid: View {
    let days: [MockDayCompletion]
    private var weekLabelWidth: CGFloat { 16 }
    private var minSquareSize: CGFloat { 13 }
    private var maxSquareSize: CGFloat { 22 }
    private var minGridSpacing: CGFloat { 4 }
    private var maxGridSpacing: CGFloat { 7 }
    private var verticalPadding: CGFloat { 32 }
    private var weeks: [[MockDayCompletion?]] {
        groupDaysByWeekRightToLeft(days)
    }
    private var monthLabels: [Int: String] {
        monthLabelsForWeeksRightToLeft(weeks)
    }
    private var dayLabels: [String] { ["S", "M", "T", "W", "T", "F", "S"] }
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - weekLabelWidth
            let availableHeight = geometry.size.height - verticalPadding
            let weekCount = weeks.count
            let idealSpacing: CGFloat = 6
            let maxPossibleSquareW = (availableWidth - CGFloat(weekCount - 1) * idealSpacing) / CGFloat(weekCount)
            let maxPossibleSquareH = (availableHeight - CGFloat(6) * idealSpacing) / 7
            let squareSize = min(max(min(maxPossibleSquareW, maxPossibleSquareH), minSquareSize), maxSquareSize)
            let gridSpacingW = max(min((availableWidth - CGFloat(weekCount) * squareSize) / CGFloat(max(weekCount - 1, 1)), maxGridSpacing), minGridSpacing)
            let gridSpacingH = max(min((availableHeight - CGFloat(7) * squareSize) / CGFloat(6), maxGridSpacing), minGridSpacing)
            let gridWidth = CGFloat(weekCount) * squareSize + CGFloat(weekCount - 1) * gridSpacingW
            let gridHeight = CGFloat(7) * squareSize + CGFloat(6) * gridSpacingH
            let horizontalPadding = max((availableWidth - gridWidth) / 2, 0)
            let verticalGridOffset = max((availableHeight - gridHeight) / 2, 0)
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: gridSpacingW) {
                    Spacer().frame(width: weekLabelWidth + horizontalPadding + 8)
                    ForEach(0..<weekCount, id: \ .self) { weekIdx in
                        if let month = monthLabels[weekIdx] {
                            Text(month)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.digitBrand.opacity(0.95))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .frame(width: squareSize, alignment: .leading)
                        } else {
                            Spacer().frame(width: squareSize)
                        }
                    }
                }
                .padding(.bottom, 2)
                HStack(alignment: .top, spacing: 0) {
                    VStack(spacing: gridSpacingH) {
                        ForEach(dayLabels, id: \ .self) { label in
                            Text(label)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.digitBrand.opacity(0.6))
                                .frame(width: weekLabelWidth, height: squareSize, alignment: .trailing)
                        }
                    }
                    .padding(.leading, 8)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: gridSpacingW) {
                            Spacer().frame(width: horizontalPadding)
                            ForEach(weeks.indices, id: \ .self) { weekIdx in
                                VStack(spacing: gridSpacingH) {
                                    ForEach(0..<7, id: \ .self) { dayIdx in
                                        if let day = weeks[weekIdx][dayIdx] {
                                            HabitGridDaySquare(day: day, squareSize: squareSize)
                                        } else {
                                            Spacer().frame(width: squareSize, height: squareSize)
                                        }
                                    }
                                }
                            }
                            Spacer().frame(width: horizontalPadding)
                        }
                        .frame(height: gridHeight)
                        .offset(y: verticalGridOffset)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    private func groupDaysByWeekRightToLeft(_ days: [MockDayCompletion]) -> [[MockDayCompletion?]] {
        guard !days.isEmpty else { return [] }
        let calendar = Calendar.current
        let sortedDays = days.sorted { $0.date < $1.date }
        var paddedDays: [MockDayCompletion?] = []
        let firstDay = sortedDays.first!.date
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let padStart = (firstWeekday - 1 + 7) % 7
        for _ in 0..<padStart { paddedDays.append(nil) }
        paddedDays.append(contentsOf: sortedDays)
        let padEnd = (7 - (paddedDays.count % 7)) % 7
        for _ in 0..<padEnd { paddedDays.append(nil) }
        var weeks: [[MockDayCompletion?]] = []
        for chunk in stride(from: 0, to: paddedDays.count, by: 7) {
            let week = Array(paddedDays[chunk..<min(chunk+7, paddedDays.count)])
            weeks.append(week)
        }
        return weeks
    }
    private func monthLabelsForWeeksRightToLeft(_ weeks: [[MockDayCompletion?]]) -> [Int: String] {
        var result: [Int: String] = [:]
        var lastMonth: Int? = nil
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        for (i, week) in weeks.enumerated() {
            if let day = week.compactMap({ $0 }).last {
                let month = Calendar.current.component(.month, from: day.date)
                if month != lastMonth {
                    let fullMonth = formatter.string(from: day.date)
                    let firstLetter = fullMonth.prefix(1)
                    result[i] = String(firstLetter)
                    lastMonth = month
                }
            }
        }
        return result
    }
}

private struct HabitGridDaySquare: View {
    let day: MockDayCompletion
    let squareSize: CGFloat
    var percent: Double {
        guard day.goal > 0, day.isActive else { return 0.0 }
        return min(Double(day.progress) / Double(day.goal), 1.0)
    }
    var color: Color {
        if !day.isActive {
            return Color.digitGrayLight.opacity(0.3)
        }
        return percent == 1.0 ? Color.digitHabitGreen : percent > 0.0 ? Color.digitHabitYellow : Color.digitHabitRed
    }
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .frame(width: squareSize, height: squareSize)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.digitBrand.opacity(0.25), lineWidth: 1.5)
            )
            .contentShape(Rectangle())
            .accessibilityLabel("\(day.progress) of \(day.goal) goals completed")
    }
}

private struct HabitGridLegend: View {
    private let stops: [Double] = [0.0, 0.25, 0.5, 0.75, 1.0]
    var body: some View {
        HStack(spacing: 6) {
            Text("Less")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.digitBrand.opacity(0.7))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            ForEach(stops, id: \ .self) { percent in
                RoundedRectangle(cornerRadius: 4)
                    .fill(percent == 1.0 ? Color.digitHabitGreen : percent > 0.0 ? Color.digitHabitYellow : Color.digitHabitRed)
                    .frame(width: 16, height: 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.digitBrand.opacity(0.18), lineWidth: 1.0)
                    )
            }
            Text("More")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.digitBrand.opacity(0.7))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

#Preview {
    StatsView()
} 

