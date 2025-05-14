import SwiftUI

struct CalenderProgressView: View {
    // Mock data for demonstration
    struct DayCompletion: Identifiable {
        let id = UUID()
        let date: Date
        let completed: Int
        let total: Int
    }
    struct HabitSummary: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let days: [DayCompletion]
    }

    // Generate mock data for the last 3 months
    private let habits: [HabitSummary] = CalenderProgressView.mockHabitsForLast3Months()

    private let currentMonth: Date = Date()
    private let previousMonth: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    private let columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 0, maximum: 28), spacing: 4), count: 7)

    private let weekDayLabels: [String] = ["M", "T", "W", "T", "F", "S", "S"]

    private func monthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    var body: some View {
        NavigationView {
            CalenderProgressContentView(habits: habits)
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    private struct CalenderProgressContentView: View {
        let habits: [CalenderProgressView.HabitSummary]
        var body: some View {
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
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(habits) { habit in
                            HabitCalendarCard(habit: habit)
                        }
                    }
                }
                .background(Color.digitBackground.ignoresSafeArea())
            }
        }
    }
}

extension CalenderProgressView {
    static func mockHabitsForLast3Months() -> [HabitSummary] {
        let calendar = Calendar.current
        let today = Date()
        guard let startOf3Months = calendar.date(byAdding: .day, value: -90, to: today) else {
            return []
        }
        let days = (0..<91).map { offset -> DayCompletion in
            let date = calendar.date(byAdding: .day, value: offset, to: startOf3Months) ?? today
            let total = Int.random(in: 1...5)
            let completed = Int.random(in: 0...total)
            return DayCompletion(date: date, completed: completed, total: total)
        }
        return [
            HabitSummary(icon: "figure.walk", title: "Work out", days: days),
            HabitSummary(icon: "bed.double.fill", title: "Wake up at 9:00", days: days.shuffled()),
            HabitSummary(icon: "brain.head.profile", title: "Meditation 30 min", days: days.shuffled()),
            HabitSummary(icon: "nosign", title: "No cigarettes", days: days.shuffled())
        ]
    }

    // Group days into weeks for GitHub-style grid
    static func groupDaysByWeek(_ days: [DayCompletion]) -> [[DayCompletion]] {
        guard let first = days.first else { return [] }
        let calendar = Calendar.current
        let weekdayOfFirst = calendar.component(.weekday, from: first.date)
        var weeks: [[DayCompletion]] = []
        var currentWeek: [DayCompletion] = Array(repeating: DayCompletion(date: Date(), completed: 0, total: 0), count: weekdayOfFirst - 1)
        for day in days {
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
            currentWeek.append(day)
        }
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                currentWeek.append(DayCompletion(date: Date(), completed: 0, total: 0))
            }
            weeks.append(currentWeek)
        }
        return weeks
    }

    // Returns a dictionary mapping week index to month label (e.g., [0: "Apr", 5: "May", ...])
    static func monthLabelsForWeeks(_ weeks: [[DayCompletion]]) -> [Int: String] {
        var result: [Int: String] = [:]
        var lastMonth: Int? = nil
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        for (i, week) in weeks.enumerated() {
            if let firstDay = week.first(where: { $0.total > 0 || $0.completed > 0 }) {
                let month = Calendar.current.component(.month, from: firstDay.date)
                if month != lastMonth {
                    result[i] = formatter.string(from: firstDay.date)
                    lastMonth = month
                }
            }
        }
        return result
    }

    static func monthLabelsForWeeksFixed(_ weeks: [[DayCompletion]]) -> [Int: String] {
        var result: [Int: String] = [:]
        var lastMonth: Int? = nil
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        for (i, week) in weeks.enumerated() {
            if let firstDay = week.first {
                let month = Calendar.current.component(.month, from: firstDay.date)
                if month != lastMonth {
                    result[i] = formatter.string(from: firstDay.date)
                    lastMonth = month
                }
            }
        }
        return result
    }

    // Group days into weeks for GitHub-style grid (right-to-left, bottom-to-top, Sunday start)
    static func groupDaysByWeekRightToLeft(_ days: [DayCompletion]) -> [[DayCompletion?]] {
        guard !days.isEmpty else { return [] }
        let calendar = Calendar.current
        // Sort days descending (most recent first)
        let sortedDays = days.sorted { $0.date > $1.date }
        var weeks: [[DayCompletion?]] = []
        var currentWeek: [DayCompletion?] = []
        let currentWeekday = calendar.component(.weekday, from: sortedDays.first!.date)
        // GitHub grid: week starts on Sunday (1), ends on Saturday (7)
        let firstWeekday = 1 // Sunday
        // Pad the first week at the top if needed
        let padCount = (currentWeekday - firstWeekday + 7) % 7
        for _ in 0..<padCount { currentWeek.append(nil) }
        for day in sortedDays {
            currentWeek.append(day)
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
        }
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 { currentWeek.append(nil) }
            weeks.append(currentWeek)
        }
        // Reverse weeks to make the most recent week on the right
        return weeks.reversed()
    }

    // Returns a dictionary mapping week index to month label (for right-to-left grid)
    static func monthLabelsForWeeksRightToLeft(_ weeks: [[DayCompletion?]]) -> [Int: String] {
        var result: [Int: String] = [:]
        var lastMonth: Int? = nil
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL" // Full month name
        for (i, week) in weeks.enumerated() {
            // Find the first non-nil day in the week (bottom-most, i.e., most recent)
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

private struct HabitCalendarCard: View {
    let habit: CalenderProgressView.HabitSummary
    private let cardHeight: CGFloat = 280 // Increased card height for more grid padding
    
    @State private var showInfoAlert = false
    
    private var percentCompletedText: String {
        let total = habit.days.reduce(0) { $0 + $1.total }
        let completed = habit.days.reduce(0) { $0 + $1.completed }
        guard total > 0 else { return "0% completed" }
        let percent = Int(round(Double(completed) / Double(total) * 100))
        return "\(percent)% completed"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title row with info button
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
            // Divider below title
            Divider()
                .background(Color.digitDivider)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            // Center grid between dividers
            ZStack(alignment: .topLeading) {
                HabitCalendarGrid(days: habit.days)
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 24)
            .frame(maxHeight: .infinity)
            // Divider above key/percent
            Divider()
                .background(Color.digitDivider)
                .padding(.top, 16)
                .padding(.horizontal, 16)
            // Percent and key row
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
    let days: [CalenderProgressView.DayCompletion]

    private var weekLabelWidth: CGFloat { 16 }
    private var minSquareSize: CGFloat { 13 }
    private var maxSquareSize: CGFloat { 22 }
    private var minGridSpacing: CGFloat { 4 }
    private var maxGridSpacing: CGFloat { 7 }
    private var verticalPadding: CGFloat { 32 }
    private var weeks: [[CalenderProgressView.DayCompletion?]] {
        CalenderProgressView.groupDaysByWeekRightToLeft(days)
    }
    private var monthLabels: [Int: String] {
        CalenderProgressView.monthLabelsForWeeksRightToLeft(weeks)
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
                // Month labels (overlay, not in grid HStack)
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
                // Grid with day labels
                HStack(alignment: .top, spacing: 0) {
                    // Day labels
                    VStack(spacing: gridSpacingH) {
                        ForEach(dayLabels, id: \ .self) { label in
                            Text(label)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.digitBrand.opacity(0.6))
                                .frame(width: weekLabelWidth, height: squareSize, alignment: .trailing)
                        }
                    }
                    .padding(.leading, 8) // More left padding for labels
                    // Grid
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
}

private struct HabitGridDaySquare: View {
    let day: CalenderProgressView.DayCompletion
    let squareSize: CGFloat
    
    var percent: Double {
        guard day.total > 0 else { return 0.0 }
        return Double(day.completed) / Double(day.total)
    }
    
    var color: Color {
        HabitGridColorScale.color(for: percent)
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
            .onTapGesture {
                // TODO: Show tooltip with date and completion info
            }
            .accessibilityLabel("\(day.completed) of \(day.total) goals completed")
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
    CalenderProgressView()
}
#endif 