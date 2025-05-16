import SwiftUI

struct CalenderProgressView: View {
    @StateObject private var viewModel: CalendarProgressViewModel

    init(habitService: HabitServiceProtocol = HabitService(), progressService: HabitProgressServiceProtocol = HabitProgressService(), userId: UUID) {
        _viewModel = StateObject(wrappedValue: CalendarProgressViewModel(habitService: habitService, progressService: progressService, userId: userId))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Full-width brand header
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Month at a Glance")
                        .font(.digitTitle2)
                        .foregroundStyle(Color.white)
                    Text("Showing your last 3 months of progress.")
                        .font(.digitBody)
                        .foregroundStyle(Color.white.opacity(0.85))
                }
                .padding(.vertical, 18)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.digitBrand.edgesIgnoringSafeArea(.top))
                .padding(.bottom, 16)
                if viewModel.isLoading {
                    ProgressView().padding()
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red).padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.habits) { habit in
                                HabitCalendarCard(habit: habit)
                            }
                        }
                    }
                    .background(Color.digitBackground.ignoresSafeArea())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct HabitCalendarCard: View {
    let habit: CalendarProgressViewModel.HabitCalendarData
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
        .cornerRadius(DigitLayout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: DigitLayout.cornerRadius)
                .stroke(Color.digitBrand, lineWidth: DigitLayout.borderWidth)
        )
        .padding(.horizontal, DigitLayout.Padding.horizontal)
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
    let days: [CalendarProgressViewModel.DayCompletion]
    private var weekLabelWidth: CGFloat { 16 }
    private var minSquareSize: CGFloat { 13 }
    private var maxSquareSize: CGFloat { 22 }
    private var minGridSpacing: CGFloat { 4 }
    private var maxGridSpacing: CGFloat { 7 }
    private var verticalPadding: CGFloat { 32 }
    private var weeks: [[CalendarProgressViewModel.DayCompletion?]] {
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
    private func groupDaysByWeekRightToLeft(_ days: [CalendarProgressViewModel.DayCompletion]) -> [[CalendarProgressViewModel.DayCompletion?]] {
        guard !days.isEmpty else { return [] }
        let calendar = Calendar.current
        // Sort days from oldest to newest (left to right)
        let sortedDays = days.sorted { $0.date < $1.date }
        // Pad the start so the first day is always a Sunday (start of week)
        var paddedDays: [CalendarProgressViewModel.DayCompletion?] = []
        let firstDay = sortedDays.first!.date
        let firstWeekday = calendar.component(.weekday, from: firstDay) // 1=Sunday
        let padStart = (firstWeekday - 1 + 7) % 7
        for _ in 0..<padStart { paddedDays.append(nil) }
        paddedDays.append(contentsOf: sortedDays)
        // Pad the end so the total count is a multiple of 7 (full weeks)
        let padEnd = (7 - (paddedDays.count % 7)) % 7
        for _ in 0..<padEnd { paddedDays.append(nil) }
        // Group into weeks (left to right)
        var weeks: [[CalendarProgressViewModel.DayCompletion?]] = []
        for chunk in stride(from: 0, to: paddedDays.count, by: 7) {
            let week = Array(paddedDays[chunk..<min(chunk+7, paddedDays.count)])
            weeks.append(week)
        }
        return weeks
    }
    private func monthLabelsForWeeksRightToLeft(_ weeks: [[CalendarProgressViewModel.DayCompletion?]]) -> [Int: String] {
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
    let day: CalendarProgressViewModel.DayCompletion
    let squareSize: CGFloat
    var percent: Double {
        guard day.goal > 0, day.isActive else { return 0.0 }
        return min(Double(day.progress) / Double(day.goal), 1.0)
    }
    var color: Color {
        if !day.isActive {
            return Color.digitGrayLight.opacity(0.3)
        }
        return HabitGridColorScale.color(for: percent)
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
            ForEach(stops, id: \.self) { percent in
                RoundedRectangle(cornerRadius: 4)
                    .fill(HabitGridColorScale.color(for: percent))
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

#if DEBUG
#Preview {
    CalenderProgressView(userId: UUID())
}
#endif 