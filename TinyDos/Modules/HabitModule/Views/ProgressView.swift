import SwiftUI
import Charts

// Place this at the top level of the file, outside any function or struct
private struct ChartBar: Identifiable {
    let id: UUID
    let date: Date
    let percent: Double
}

extension ProgressViewModel.HabitCalendarData: HabitCalendarDataProtocol {
    typealias Day = ProgressViewModel.HabitCalendarDay
}
extension ProgressViewModel.HabitCalendarDay: HabitCalendarDayProtocol {}

struct ProgressView: View {
    @StateObject private var viewModel: ProgressViewModel
    @State private var showDeleteAlert = false
    @State private var habitToDelete: UUID? = nil
    @State private var selectedDay: Int? = nil
    
    // Dependency injection initializer
    init(habitService: HabitServiceProtocol = HabitService(), progressService: HabitProgressServiceProtocol = HabitProgressService(), userId: UUID? = nil) {
        let resolvedUserId: UUID
        if let userId = userId {
            resolvedUserId = userId
        } else {
            // Fallback to a dummy UUID for now; production should inject real userId
            resolvedUserId = UUID()
        }
        _viewModel = StateObject(wrappedValue: ProgressViewModel(habitRepository: HabitRepository(), progressRepository: ProgressRepository(), userId: resolvedUserId))
    }
    
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
            .padding(.horizontal, DigitLayout.Padding.horizontal)
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
                ForEach(ProgressViewModel.Period.allCases.indices, id: \ .self) { idx in
                    let period = ProgressViewModel.Period.allCases[idx]
                    Button(action: { withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { viewModel.selectedPeriod = period } }) {
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
                                            .matchedGeometryEffect(id: "segment", in: segmentNamespace)
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
        .padding(.horizontal, DigitLayout.Padding.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 20)
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
        .padding(.horizontal, DigitLayout.Padding.horizontal)
        .padding(.top, 12)
    }
    
    // MARK: - Extracted: Chart or Grid Section
    private var chartAndSummaryCard: some View {
        VStack(spacing: 0) {
            ProgressBarChart(data: Array(viewModel.barChartData.suffix(7)))
                .padding(.top, 24)
                .padding(.bottom, 8)
            Divider()
                .background(Color.digitDivider)
            HabitSummaryRow(perfect: viewModel.perfectCount, partial: viewModel.partialCount, missed: viewModel.missedCount, horizontalPadding: 0)
                .padding(.vertical, 12)
        }
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.digitBrand.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 2, y: 2)
    }
    
    // MARK: - Extracted: Summary Cards Section
    private var completionListSection: some View {
        let calendar = Calendar.current
        let now = Date()
        let selectedDate: Date = {
            if let selectedDay = selectedDay {
                let components = calendar.dateComponents([.year, .month], from: now)
                let firstOfMonth = calendar.date(from: components) ?? now
                return calendar.date(byAdding: .day, value: selectedDay - 1, to: firstOfMonth) ?? now
            } else {
                return now
            }
        }()
        let completedHabits = viewModel.completedHabits(for: selectedDate)
        return VStack(alignment: .leading, spacing: 0) {
            if completedHabits.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(Color.progressCompleted)
                    Text("No completed habits for this day.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color.digitSecondaryText)
                }
                .frame(maxWidth: .infinity, minHeight: 80)
                .padding(.vertical, 16)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(completedHabits, id: \ .id) { habit in
                        HStack(spacing: 12) {
                            Image(systemName: habit.icon)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color.progressCompleted)
                            Text(habit.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.digitBrand)
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.progressCompleted)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.vertical, 12)
            }
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Main Content (extracted for compiler performance)
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Header title styled like 'Today' in Home tab
            HStack {
                Text("Progress")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.black)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }
            .padding(.top, 0)
            .padding(.horizontal, DigitLayout.Padding.horizontal)
            Spacer().frame(height: 24)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    chartAndSummaryCard
                    calendarSection
                    completionListSection
                }
                .padding(.horizontal, DigitLayout.Padding.horizontal)
            }
        }
        .background(Color.digitGrayLight)
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
    
    // Place calendarSection here so it can access viewModel
    private var calendarSection: some View {
        VStack(spacing: 0) {
            CalendarGridView(
                month: Date(),
                completedDays: viewModel.completedDays,
                partialDays: viewModel.partialDays,
                missedDays: viewModel.missedDays,
                selectedDay: selectedDay,
                onDaySelected: { selectedDay = $0 }
            )
            .padding(.top, 0)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.digitBrand.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
        .padding(.top, 8)
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
private struct ProgressBarChart: View {
    let data: [ProgressViewModel.DayStat] // Should be exactly 7 days
    private let barColor = Color(#colorLiteral(red: 0.22, green: 0.18, blue: 1.0, alpha: 1.0)) // Use your brand blue
    private let emptyBarColor = Color(.systemGray5)
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 20) {
                ForEach(0..<7, id: \ .self) { i in
                    let stat = i < data.count ? data[i] : nil
                    VStack(spacing: 0) {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(emptyBarColor)
                                .frame(width: 28, height: 180)
                                .cornerRadius(8, corners: [.topLeft, .topRight])
                            if let stat = stat {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(barColor)
                                    .frame(width: 28, height: CGFloat(stat.percent) * 180)
                                    .cornerRadius(8, corners: [.topLeft, .topRight])
                            }
                        }
                        .frame(height: 180)
                        .padding(.bottom, 8)
                        Text(dayLabels[i])
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.digitSecondaryText)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal, 0)
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
            summaryCell(icon: "checkmark.circle.fill", iconColor: .progressCompleted, label: "PERFECT", value: perfect)
            shortDivider
            summaryCell(icon: "exclamationmark.circle.fill", iconColor: .progressPartial, label: "PARTIAL", value: partial)
            shortDivider
            summaryCell(icon: "xmark.circle.fill", iconColor: .progressMissed, label: "MISSED", value: missed)
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
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(.systemGray))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Calendar Grid View (Production, Reference-Matched)
private struct CalendarGridView: View {
    let month: Date
    let completedDays: [Int]
    let partialDays: [Int]
    let missedDays: [Int]
    let selectedDay: Int?
    let onDaySelected: (Int) -> Void
    
    private let daysOfWeek = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Month label and navigation
            HStack(spacing: 0) {
                Text(monthLabel)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.black)
                    .padding(.leading, 20)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(.systemGray3))
                        .padding(.horizontal, 8)
                }
                Button(action: {}) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(.systemGray3))
                        .padding(.horizontal, 8)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 12)
            // Days of week header
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \ .self) { day in
                    Text(day)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.digitSecondaryText)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
            // Month grid
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month], from: month)
            let firstOfMonth = calendar.date(from: components) ?? month
            let range = calendar.range(of: .day, in: .month, for: firstOfMonth) ?? 1..<31
            let firstWeekday = (calendar.component(.weekday, from: firstOfMonth) + 5) % 7 // 0=Mon, 6=Sun
            let days = Array(range)
            let totalCells = days.count + firstWeekday
            let rows = Int(ceil(Double(totalCells) / 7.0))
            VStack(spacing: 8) {
                ForEach(0..<rows, id: \ .self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \ .self) { col in
                            let cell = row * 7 + col
                            if cell < firstWeekday || cell - firstWeekday >= days.count {
                                Spacer().frame(maxWidth: .infinity, minHeight: 38)
                            } else {
                                let day = days[cell - firstWeekday]
                                let isToday = calendar.isDateInToday(calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) ?? firstOfMonth)
                                let isSelected = !isToday && (selectedDay == day)
                                VStack(spacing: 2) {
                                    ZStack {
                                        if isToday {
                                            Circle()
                                                .fill(Color.digitBrand)
                                                .frame(width: 32, height: 32)
                                        } else if isSelected {
                                            Circle()
                                                .fill(Color.black)
                                                .frame(width: 32, height: 32)
                                        }
                                        Text("\(day)")
                                            .font(.system(size: 16, weight: (isToday || isSelected) ? .bold : .regular))
                                            .foregroundStyle((isToday || isSelected) ? Color.white : Color.black)
                                    }
                                    // Dot indicator
                                    if completedDays.contains(day) {
                                        Circle().fill(Color.progressCompleted).frame(width: 7, height: 7)
                                    } else if partialDays.contains(day) {
                                        Circle().fill(Color.progressPartial).frame(width: 7, height: 7)
                                    } else if missedDays.contains(day) {
                                        Circle().fill(Color.progressMissed).frame(width: 7, height: 7)
                                    } else {
                                        Spacer().frame(height: 7)
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 38)
                                .accessibilityLabel("Day \(day) \(completedDays.contains(day) ? "completed" : partialDays.contains(day) ? "partial" : missedDays.contains(day) ? "missed" : "")")
                                .contentShape(Rectangle())
                                .onTapGesture { onDaySelected(day) }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
    }
    private var monthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: month)
    }
}

// Define custom colors for completed, missed, and partial
private extension Color {
    static let progressCompleted = Color(red: 0x12/255, green: 0x8D/255, blue: 0x65/255)
    static let progressMissed = Color(red: 0xF6/255, green: 0x3D/255, blue: 0x3D/255)
    static let progressPartial = Color(red: 0xFF/255, green: 0xA1/255, blue: 0x00/255)
}

// Add a View extension for per-corner radius
private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    ProgressView()
} 

