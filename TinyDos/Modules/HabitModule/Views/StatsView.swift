import SwiftUI
import Charts

// Place this at the top level of the file, outside any function or struct
private struct ChartBar: Identifiable {
    let id: UUID
    let date: Date
    let percent: Double
}

extension StatsViewModel.HabitCalendarData: HabitCalendarDataProtocol {
    typealias Day = StatsViewModel.HabitCalendarDay
}
extension StatsViewModel.HabitCalendarDay: HabitCalendarDayProtocol {}

struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel
    @State private var showDeleteAlert = false
    @State private var habitToDelete: UUID? = nil
    
    // Dependency injection initializer
    init(habitService: HabitServiceProtocol = HabitService(), progressService: HabitProgressServiceProtocol = HabitProgressService(), userId: UUID? = nil) {
        let resolvedUserId: UUID
        if let userId = userId {
            resolvedUserId = userId
        } else {
            // Fallback to a dummy UUID for now; production should inject real userId
            resolvedUserId = UUID()
        }
        _viewModel = StateObject(wrappedValue: StatsViewModel(habitService: habitService, progressService: progressService, userId: resolvedUserId))
    }
    
    @Namespace private var segmentNamespace
    
    private let horizontalPadding: CGFloat = DigitLayout.Padding.horizontal
    
    // MARK: - New: Header Bar
    private var headerBar: some View {
        ZStack {
            Color.digitBrand
                .frame(height: 48)
                .ignoresSafeArea(edges: .top)
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.digitAccentRed)
                    .frame(width: 4, height: 24)
                Text("Your Stats")
                    .font(.plusJakartaSans(size: 22, weight: .bold))
                    .foregroundStyle(Color.white)
                Spacer()
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
    
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
        ZStack {
            RoundedRectangle(cornerRadius: DigitLayout.cornerRadius, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 2, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: DigitLayout.cornerRadius, style: .continuous)
                        .stroke(Color.digitBrand.opacity(0.12), lineWidth: 1.5)
                )
            HStack(spacing: 0) {
                ForEach(StatsViewModel.Period.allCases.indices, id: \ .self) { idx in
                    let period = StatsViewModel.Period.allCases[idx]
                    Button(action: { viewModel.selectedPeriod = period }) {
                        Text(period.title)
                            .font(.plusJakartaSans(size: 16, weight: .semibold))
                            .foregroundStyle(viewModel.selectedPeriod == period ? Color.white : Color.digitBrand)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                ZStack {
                                    if viewModel.selectedPeriod == period {
                                        RoundedRectangle(cornerRadius: DigitLayout.cornerRadius - 2, style: .continuous)
                                            .fill(Color.digitAccentRed)
                                            .shadow(color: Color.digitAccentRed.opacity(0.10), radius: 2, y: 1)
                                            .padding(.horizontal, 2)
                                            .padding(.vertical, 2)
                                    } else {
                                        Color.clear
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: DigitLayout.cornerRadius - 2, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
        .frame(height: 44)
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
    private var chartOrGridSection: some View {
        let avgPercent = viewModel.barChartData.isEmpty ? 0.0 : viewModel.barChartData.map { $0.percent }.reduce(0, +) / Double(viewModel.barChartData.count)
        let chartData: [StatsViewModel.DayStat] = {
            if viewModel.selectedPeriod == .year {
                let calendar = Calendar.current
                let grouped = Dictionary(grouping: viewModel.barChartData) { calendar.component(.month, from: $0.date) }
                return grouped.sorted { $0.key < $1.key }.map { (month, days) in
                    let avg = days.map { $0.percent }.reduce(0, +) / Double(days.count)
                    let date = days.first?.date ?? Date()
                    return StatsViewModel.DayStat(date: date, percent: avg)
                }
            } else {
                return viewModel.barChartData
            }
        }()
        return CompletionBarChartCard(data: chartData, avgPercent: avgPercent, period: viewModel.selectedPeriod, horizontalPadding: horizontalPadding)
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
                        HabitStatCard(stat: stat, horizontalPadding: horizontalPadding)
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 32)
            }
        }
    }
    
    // MARK: - Main Content (extracted for compiler performance)
    private var mainContent: some View {
        VStack(spacing: 0) {
            headerBar
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    segmentedControl
                    VStack(alignment: .leading, spacing: 16) {
                        chartOrGridSection
                            .background(Color.white)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.digitBrand.opacity(0.12), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 2, y: 2)
                            .padding(.horizontal, horizontalPadding)
                    }

                    HabitSummaryRow(perfect: viewModel.perfectCount, partial: viewModel.partialCount, missed: viewModel.missedCount, horizontalPadding: 0)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.digitBrand.opacity(0.12), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 2, y: 2)
                        .padding(.horizontal, horizontalPadding)

                    // Calendar Cards
                    VStack(spacing: 8) {
                        ForEach(viewModel.calendarData) { habit in
                            HabitCalendarCard(habit: habit)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        habitToDelete = habit.id
                                        showDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    Button {
                                        // Optionally implement stop logic here
                                    } label: {
                                        Label("Stop", systemImage: "pause.circle")
                                    }
                                }
                                .padding(.horizontal, horizontalPadding)
                        }
                    }
                    .padding(.bottom, 8)
                }
                .padding(.top, 24)
                .background(Color.digitGrayLight)
            }
        }
        .alert("Delete Habit?", isPresented: $showDeleteAlert, presenting: habitToDelete) { id in
            Button("Delete", role: .destructive) {
                Task { await viewModel.deleteHabit(id: id) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("Are you sure you want to delete this habit? This action cannot be undone.")
        }
    }
    
    // MARK: - Main Body
    var body: some View {
        mainContent
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
                        ForEach(0..<7) { dayIndex in
                            let percent: Double = 0.0 // Replace with actual percent logic if available
                            RoundedRectangle(cornerRadius: squareCornerRadius)
                                .stroke(Color.digitBrand, lineWidth: 0.8)
                                .background(RoundedRectangle(cornerRadius: squareCornerRadius).fill(HabitGridColorScale.color(for: percent)))
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
    let horizontalPadding: CGFloat
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: stat.icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.digitBrand)
            Text(stat.title)
                .font(.plusJakartaSans(size: 16, weight: .semibold))
                .foregroundStyle(Color.digitBrand)
            Spacer()
            Text(stat.value)
                .font(.plusJakartaSans(size: 16, weight: .semibold))
                .foregroundStyle(Color.digitBrand)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 2, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.digitBrand, lineWidth: 1.2)
        )
        .padding(.horizontal, horizontalPadding)
    }
}

// MARK: - New Bar Chart Card (Production Style)
private struct CompletionBarChartCard: View {
    let data: [StatsViewModel.DayStat]
    let avgPercent: Double
    let period: StatsViewModel.Period
    let horizontalPadding: CGFloat
    @State private var scrollTarget: UUID? = nil

    private var chartBars: [ChartBar] {
        data.map { ChartBar(id: $0.id, date: $0.date, percent: $0.percent) }
    }

    private var weekChart: some View {
        Chart(data) { day in
            BarMark(
                x: .value("Date", day.date, unit: .day),
                y: .value("Completion", day.percent)
            )
            .foregroundStyle(Color.digitAccentRed)
            .cornerRadius(4)
        }
        .chartYScale(domain: 0.0...1.0)
        .chartYAxis {
            AxisMarks(position: .leading, values: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [2]))
                    .foregroundStyle(Color.digitBrand.opacity(0.15))
                AxisTick()
                    .foregroundStyle(Color.digitBrand.opacity(0.15))
                AxisValueLabel() {
                    if let percent = value.as(Double.self) {
                        Text("\(Int(percent * 100))%")
                            .foregroundStyle(Color.digitBrand)
                            .font(.system(size: 12, weight: .medium))
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel() {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.weekday(.abbreviated))
                            .foregroundStyle(Color.digitBrand)
                            .font(.system(size: 12, weight: .medium))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 320)
        .chartXAxis(.automatic)
    }

    private var monthBarChart: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Chart {
                ForEach(chartBars) { bar in
                    BarMark(
                        x: .value("Date", bar.date, unit: .day),
                        y: .value("Completion", bar.percent)
                    )
                    .foregroundStyle(Color.digitAccentRed)
                    .cornerRadius(4)
                    .accessibilityLabel(Text("\(bar.date, format: .dateTime.day()): \(Int(bar.percent * 100))%"))
                }
            }
            .chartYScale(domain: 0.0...1.0)
            .chartYAxis {
                AxisMarks(position: .leading, values: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [2]))
                        .foregroundStyle(Color.digitBrand.opacity(0.15))
                    AxisTick()
                        .foregroundStyle(Color.digitBrand.opacity(0.15))
                    AxisValueLabel() {
                        if let percent = value.as(Double.self) {
                            Text("\(Int(percent * 100))%")
                                .foregroundStyle(Color.digitBrand)
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel() {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.day())
                                .foregroundStyle(Color.digitBrand)
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(width: CGFloat(chartBars.count) * 32, height: 320)
            .chartXAxis(.automatic)
        }
    }

    private var monthChart: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                monthBarChart
            }
            .onAppear {
                if let today = chartBars.first(where: { Calendar.current.isDateInToday($0.date) }) {
                    scrollTarget = today.id
                } else if let last = chartBars.last {
                    scrollTarget = last.id
                }
                if let target = scrollTarget {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(target, anchor: .center)
                        }
                    }
                }
            }
            .onChange(of: data) { _, _ in
                if let today = chartBars.first(where: { Calendar.current.isDateInToday($0.date) }) {
                    scrollTarget = today.id
                } else if let last = chartBars.last {
                    scrollTarget = last.id
                }
                if let target = scrollTarget {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(target, anchor: .center)
                        }
                    }
                }
            }
        }
    }

    private var yearChart: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Chart(data) {
                BarMark(
                    x: .value("Month", $0.date, unit: .month),
                    y: .value("Completion", $0.percent)
                )
                .foregroundStyle(Color.digitAccentRed)
                .cornerRadius(4)
            }
            .chartYScale(domain: 0.0...1.0)
            .chartYAxis {
                AxisMarks(position: .leading, values: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [2]))
                        .foregroundStyle(Color.digitBrand.opacity(0.15))
                    AxisTick()
                        .foregroundStyle(Color.digitBrand.opacity(0.15))
                    AxisValueLabel() {
                        if let percent = value.as(Double.self) {
                            Text("\(Int(percent * 100))%")
                                .foregroundStyle(Color.digitBrand)
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisValueLabel() {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.month(.abbreviated))
                                .foregroundStyle(Color.digitBrand)
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(width: CGFloat(data.count) * 32, height: 320)
            .chartXAxis(.automatic)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("AVG COMPLETION RATE")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(avgPercent * 100))%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.top, 16)
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, 8)
            Divider()
                .background(Color.digitDivider)
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 8)
            Group {
                switch period {
                case .week:
                    weekChart
                case .month:
                    monthChart
                case .year:
                    yearChart
                }
            }
        }
    }
}

// MARK: - Habit Summary Row
private struct HabitSummaryRow: View {
    let perfect: Int
    let partial: Int
    let missed: Int
    let horizontalPadding: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            summaryCell(icon: "circle.fill", iconColor: .blue, label: "PERFECT", value: perfect)
            shortDivider
            summaryCell(icon: "circle.lefthalf.filled", iconColor: .orange, label: "PARTIAL", value: partial)
            shortDivider
            summaryCell(icon: "xmark.circle.fill", iconColor: .red, label: "MISSED", value: missed)
        }
        .padding(.vertical, 6)
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
                .foregroundStyle(Color.secondary)
            Text("\(value)")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.digitBrand)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StatsView()
} 

