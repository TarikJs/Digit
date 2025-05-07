import SwiftUI

// Add this struct to define habit data
struct HabitData {
    var title: String
    var icon: String
    var value: Int
    var max: Int
    var color: Color
    var unit: String
}

// Helper to check if habit was completed today
private func isCompletedToday(_ completions: [Date]) -> Bool {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    return completions.contains { completion in
        calendar.isDate(calendar.startOfDay(for: completion), inSameDayAs: today)
    }
}

// Add at the top level, before other constants
private enum UIConstants {
    static let borderWidth: CGFloat = 1.5
    static let cornerRadius: CGFloat = 7
}

// MARK: - Home Header View
struct HomeHeaderView: View {
    let userName: String
    let showingCalendar: Binding<Bool>
    let showingAddHabit: Binding<Bool>
    
    private let headerShadowColor = Color(hex: "#23409A")
    
    var body: some View {
        HStack(spacing: Layout.horizontalSpacing) {
            // Profile button and name
            HStack(spacing: Layout.horizontalSpacing) {
                Button {
                    // Profile action
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: Layout.headerCornerRadius)
                            .fill(Color.offWhite)
                            .frame(width: Layout.headerButtonSize, height: Layout.headerButtonSize)
                            .shadow(color: headerShadowColor, radius: 0, x: Layout.headerShadowOffset, y: Layout.headerShadowOffset)
                            .overlay(RoundedRectangle(cornerRadius: Layout.headerCornerRadius).stroke(Color.brandBlue, lineWidth: UIConstants.borderWidth))
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: Layout.headerIconSize, height: Layout.headerIconSize)
                            .foregroundColor(.brandBlue)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Hello,")
                        .font(.subheadline)
                        .foregroundColor(.brandBlue)
                    Text(userName)
                        .font(.title2).bold()
                        .foregroundColor(.brandBlue)
                }
            }
            
            Spacer()
            
            // Calendar and Add buttons
            HStack(spacing: Layout.horizontalSpacing) {
                Button {
                    showingCalendar.wrappedValue = true
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: Layout.headerCornerRadius)
                            .fill(Color.offWhite)
                            .frame(width: Layout.headerButtonSize, height: Layout.headerButtonSize)
                            .shadow(color: headerShadowColor, radius: 0, x: Layout.headerShadowOffset, y: Layout.headerShadowOffset)
                            .overlay(RoundedRectangle(cornerRadius: Layout.headerCornerRadius).stroke(Color.brandBlue, lineWidth: UIConstants.borderWidth))
                        Image(systemName: "calendar")
                            .resizable()
                            .frame(width: Layout.headerIconSize, height: Layout.headerIconSize)
                            .foregroundColor(.brandBlue)
                    }
                }
                
                Button {
                    showingAddHabit.wrappedValue = true
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: Layout.headerCornerRadius)
                            .fill(Color.brandBlue)
                            .frame(width: Layout.headerButtonSize, height: Layout.headerButtonSize)
                            .shadow(color: .white, radius: 0, x: 1.5, y: 1.5)
                            .shadow(color: headerShadowColor, radius: 0, x: Layout.headerShadowOffset, y: Layout.headerShadowOffset)
                            .overlay(RoundedRectangle(cornerRadius: Layout.headerCornerRadius).stroke(Color.brandBlue, lineWidth: UIConstants.borderWidth))
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: Layout.headerIconSize, height: Layout.headerIconSize)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .frame(height: Layout.headerHeight)
        .padding(.vertical, 0)
    }
}

// Extract habit carousel into its own view
struct HabitCarouselView: View {
    let habitPages: [[HabitData]]
    @Binding var currentPage: Int
    let safeHorizontalPadding: CGFloat
    @Binding var habitValues: [String: Int]
    
    // Animation and layout constants
    private let transitionAnimation: Animation = .interpolatingSpring(mass: 0.8, stiffness: 350, damping: 25, initialVelocity: 0.7)
    private let cardSpacing: CGFloat = 32
    private let maxDotsToShow: Int = 5
    private let carouselVerticalPadding: CGFloat = 4
    
    // Haptic feedback generator
    private let haptics = UIImpactFeedbackGenerator(style: .light)
    
    // Track the previous page for transition direction
    @State private var previousPage = 0
    
    // Flatten the habit array for paired display (two cards per page)
    private var pairedHabits: [[HabitData]] {
        let flattened = habitPages.flatMap { $0 }
        return stride(from: 0, to: flattened.count, by: 2).map {
            let start = $0
            let end = min(start + 2, flattened.count)
            return Array(flattened[start..<end])
        }
    }
    
    // Helper function to create binding for habit value
    private func habitBinding(for title: String) -> Binding<Int> {
        Binding(
            get: { habitValues[title] ?? 0 },
            set: { habitValues[title] = $0 }
        )
    }
    
    // Calculate which dots to show
    private var visibleDotIndices: [Int] {
        let totalDots = pairedHabits.count
        guard totalDots > maxDotsToShow else { return Array(0..<totalDots) }
        
        let halfMax = maxDotsToShow / 2
        if currentPage <= halfMax {
            return Array(0..<maxDotsToShow)
        } else if currentPage >= totalDots - halfMax {
            return Array((totalDots - maxDotsToShow)..<totalDots)
        } else {
            return Array((currentPage - halfMax)...(currentPage + halfMax))
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                let availableWidth = geometry.size.width - (safeHorizontalPadding * 2)
                let cardWidth = (availableWidth - cardSpacing) / 2
                
                TabView(selection: $currentPage) {
                    ForEach(pairedHabits.indices, id: \.self) { pageIndex in
                        HStack(spacing: cardSpacing) {
                            ForEach(pairedHabits[pageIndex], id: \.title) { habit in
                                QuantHabitBlock(
                                    title: habit.title,
                                    icon: habit.icon,
                                    value: habitBinding(for: habit.title),
                                    max: habit.max,
                                    color: habit.color,
                                    unit: habit.unit
                                )
                                .frame(width: cardWidth)
                                .shadow(color: Color.brandBlue.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            if pairedHabits[pageIndex].count == 1 {
                                Spacer()
                                    .frame(width: cardWidth)
                            }
                        }
                        .tag(pageIndex)
                        .padding(.horizontal, safeHorizontalPadding)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: currentPage) { oldValue, newValue in
                    haptics.impactOccurred()
                    withAnimation(.easeInOut(duration: 0.3)) {
                    }
                    previousPage = newValue
                }
            }
            .frame(height: 165)
            
            // Modern pagination indicator with 3D effect
            HStack(spacing: 8) {
                ForEach(visibleDotIndices, id: \.self) { index in
                    // Active dot with pill shape and 3D shadow
                    if currentPage == index {
                        Capsule()
                            .fill(Color.brandBlue)
                            .frame(width: 24, height: 8)
                            .shadow(color: Color(hex: "#23409A").opacity(0.3), radius: 0, x: 2, y: 2)
                            .overlay(
                                Capsule()
                                    .stroke(Color.brandBlue, lineWidth: 1.5)
                            )
                    } else {
                        // Inactive dot
                        Circle()
                            .fill(Color.brandBlue.opacity(0.2))
                            .frame(width: 8, height: 8)
                            .overlay(
                                Circle()
                                    .stroke(Color.brandBlue.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Add ellipsis for truncated dots
                    if index == visibleDotIndices.first && index > 0 {
                        Text("•")
                            .foregroundColor(.brandBlue.opacity(0.5))
                            .font(.system(size: 8, weight: .bold))
                    }
                    if index == visibleDotIndices.last && index < pairedHabits.count - 1 {
                        Text("•")
                            .foregroundColor(.brandBlue.opacity(0.5))
                            .font(.system(size: 8, weight: .bold))
                    }
                }
            }
            .padding(.top, 8)
            .animation(.easeInOut(duration: 0.2), value: currentPage)
        }
        .padding(.vertical, carouselVerticalPadding)
    }
}

// MARK: - Layout Constants
private enum Layout {
    // Screen-based calculations
    static let screenWidth = UIScreen.main.bounds.width
    static let sectionWidthMultiplier: CGFloat = 0.92
    static let contentWidth: CGFloat = screenWidth * sectionWidthMultiplier
    static let dynamicHorizontalPadding: CGFloat = (screenWidth - contentWidth) / 2
    
    // Section styling
    static let sectionCornerRadius: CGFloat = UIConstants.cornerRadius
    static let sectionBorderWidth: CGFloat = UIConstants.borderWidth
    static let sectionShadowOffset: CGFloat = 3
    static let sectionBorderOpacity: Double = 0.1
    static let sectionContentPadding: CGFloat = 16
    
    // Account for border width in content width calculations
    static let adjustedContentWidth: CGFloat = contentWidth - (UIConstants.borderWidth * 2)
    
    // Spacing
    static let sectionSpacing: CGFloat = 8
    static let verticalSpacing: CGFloat = 4
    static let horizontalSpacing: CGFloat = 12
    
    // Calendar specific
    static let calendarWidthMultiplier: CGFloat = 0.85
    static let calendarWidth: CGFloat = screenWidth * calendarWidthMultiplier
    static let calendarItemHeight: CGFloat = 46
    static let calendarItemSpacing: CGFloat = 6
    static let calendarCornerRadius: CGFloat = UIConstants.cornerRadius
    static let calendarBorderWidth: CGFloat = UIConstants.borderWidth
    static let calendarShadowOffset: CGFloat = 3
    static let calendarVerticalPadding: CGFloat = 8
    
    // Header specific
    static let headerHeight: CGFloat = 44
    static let headerButtonSize: CGFloat = 36
    static let headerIconSize: CGFloat = 20
    static let headerCornerRadius: CGFloat = UIConstants.cornerRadius
    static let headerBorderWidth: CGFloat = UIConstants.borderWidth
    static let headerShadowOffset: CGFloat = 3
    static let headerTopPadding: CGFloat = 0
    static let headerBottomPadding: CGFloat = 0
}

struct HomeView: View {
    @State private var showingCalendar = false
    @State private var showingAddHabit = false
    @State private var showingCompletionList = false
    @State private var currentPage = 0
    
    // Offset and spacing controls
    @State private var verticalOffset: CGFloat = 70 // Overall content offset
    @State private var headerSpacing: CGFloat = 20 // Space between header and first section
    @State private var sectionSpacing: CGFloat = 16 // Space between sections
    
    // Dummy data for preview
    let userName = "Name Surname"
    
    // State for habit values
    @State private var habitValues: [String: Int] = [
        "Drink water": 1,
        "Read book": 15,
        "Exercise": 45,
        "Meditate": 20,
        "Write journal": 2,
        "Practice guitar": 15,
        "Study language": 10,
        "Take vitamins": 1,
        "Walk steps": 5000,
        "Stretch": 5,
        "Drink tea": 2,
        "Code practice": 30
    ]
    
    // Flatten habits into a single array
    private let habitPages: [[HabitData]] = [
        [
            HabitData(title: "Drink water", icon: "waterbottle", value: 1, max: 10, color: .accentLime, unit: "glasses")
        ],
        [
            HabitData(title: "Read book", icon: "text.book.closed", value: 15, max: 30, color: .accentPurple, unit: "pages")
        ],
        [
            HabitData(title: "Exercise", icon: "figure.run", value: 45, max: 60, color: .accentLime, unit: "minutes")
        ],
        [
            HabitData(title: "Meditate", icon: "brain.head.profile", value: 20, max: 30, color: .accentPurple, unit: "minutes")
        ],
        [
            HabitData(title: "Write journal", icon: "pencil.line", value: 2, max: 3, color: .accentLime, unit: "pages")
        ],
        [
            HabitData(title: "Practice guitar", icon: "guitars", value: 15, max: 30, color: .accentPurple, unit: "minutes")
        ],
        [
            HabitData(title: "Study language", icon: "text.bubble", value: 10, max: 20, color: .accentLime, unit: "minutes")
        ],
        [
            HabitData(title: "Take vitamins", icon: "pill", value: 1, max: 2, color: .accentPurple, unit: "pills")
        ],
        [
            HabitData(title: "Walk steps", icon: "figure.walk", value: 5000, max: 10000, color: .accentLime, unit: "steps")
        ],
        [
            HabitData(title: "Stretch", icon: "figure.flexibility", value: 5, max: 15, color: .accentPurple, unit: "minutes")
        ],
        [
            HabitData(title: "Drink tea", icon: "cup.and.saucer", value: 2, max: 4, color: .accentLime, unit: "cups")
        ],
        [
            HabitData(title: "Code practice", icon: "chevron.left.forwardslash.chevron.right", value: 30, max: 60, color: .accentPurple, unit: "minutes")
        ]
    ]
    
    // Helper function to create binding for habit value
    private func habitBinding(for title: String) -> Binding<Int> {
        Binding(
            get: { habitValues[title] ?? 0 },
            set: { habitValues[title] = $0 }
        )
    }
    
    // Replace habits with proper Habit model
    @State private var habits = [Habit]()
    
    // Add these date-related properties
    @State private var selectedDate = Date()
    private let calendar = Calendar.current
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background color
                Color.offWhite.ignoresSafeArea()
                
                // Replace ScrollView with VStack
                VStack(spacing: headerSpacing) {
                    // Header
                    HomeHeaderView(
                        userName: userName,
                        showingCalendar: $showingCalendar,
                        showingAddHabit: $showingAddHabit
                    )
                    .padding(.horizontal, Layout.dynamicHorizontalPadding)
                    
                    // All sections container
                    VStack(spacing: sectionSpacing) {
                        // Calendar Section
                        VStack(spacing: 4) {
                            HStack {
                                Text("Calendar")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.brandBlue)
                                Spacer()
                            }
                            .frame(width: Layout.contentWidth)
                            
                            CalendarView(selectedDate: $selectedDate)
                                .frame(width: Layout.adjustedContentWidth)
                                .padding(UIConstants.borderWidth)
                                .frame(width: Layout.contentWidth)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: Layout.sectionCornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Layout.sectionCornerRadius)
                                        .stroke(Color.brandBlue, lineWidth: UIConstants.borderWidth)
                                )
                                .shadow(color: Color.brandBlue.opacity(0.1), radius: 0, x: 0, y: Layout.sectionShadowOffset)
                        }
                        
                        // Daily Progress Section
                        VStack(spacing: 4) {
                            HStack {
                                Text("Daily Progress")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.brandBlue)
                                Spacer()
                            }
                            .frame(width: Layout.contentWidth)
                            
                            VStack {
                                if habits.isEmpty {
                                    Spacer()
                                    Text("No progress yet. Tap + to add a habit.")
                                        .font(.headline)
                                        .foregroundColor(.brandBlue)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                } else {
                                    HabitCarouselView(
                                        habitPages: habitPages,
                                        currentPage: $currentPage,
                                        safeHorizontalPadding: Layout.sectionContentPadding,
                                        habitValues: $habitValues
                                    )
                                }
                            }
                            .frame(width: Layout.adjustedContentWidth, height: 235)
                            .padding(UIConstants.borderWidth)
                            .frame(width: Layout.contentWidth)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: Layout.sectionCornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: Layout.sectionCornerRadius)
                                    .stroke(Color.brandBlue, lineWidth: UIConstants.borderWidth)
                            )
                            .shadow(color: Color.brandBlue.opacity(0.1), radius: 0, x: 0, y: Layout.sectionShadowOffset)
                        }
                        
                        // Daily Tasks Section
                        VStack(spacing: 4) {
                            HStack {
                                Text("Daily Tasks")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.brandBlue)
                                Spacer()
                            }
                            .frame(width: Layout.contentWidth)
                            
                            VStack {
                                if habits.isEmpty {
                                    Spacer()
                                    Text("No daily tasks. Start by adding a habit.")
                                        .font(.headline)
                                        .foregroundColor(.brandBlue)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                } else {
                                    // Tasks List Container
                                    ScrollView {
                                        VStack(spacing: StyleConstants.cardSpacing) {
                                            ForEach($habits) { $habit in
                                                CompletionCard(
                                                    icon: habit.iconName,
                                                    title: habit.name,
                                                    isCompleted: isCompletedToday(habit.completions),
                                                    color: habit.color.color,
                                                    onTap: {
                                                        withAnimation(.spring(response: 0.3)) {
                                                            let today = Date()
                                                            if isCompletedToday(habit.completions) {
                                                                habit.completions.removeAll { completion in
                                                                    Calendar.current.isDate(completion, inSameDayAs: today)
                                                                }
                                                            } else {
                                                                habit.completions.append(today)
                                                            }
                                                        }
                                                    }
                                                )
                                            }
                                        }
                                        .padding(StyleConstants.completionListPadding)
                                    }
                                    .frame(height: 220)
                                }
                            }
                            .frame(width: Layout.adjustedContentWidth, height: 210)
                            .padding(UIConstants.borderWidth)
                            .frame(width: Layout.contentWidth)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: Layout.sectionCornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: Layout.sectionCornerRadius)
                                    .stroke(Color.brandBlue, lineWidth: UIConstants.borderWidth)
                            )
                            .shadow(color: Color.brandBlue.opacity(0.1), radius: 0, x: 0, y: Layout.sectionShadowOffset)
                        }
                    }
                }
                .offset(y: verticalOffset)
                .ignoresSafeArea(edges: .top)
            }
        }
        .sheet(isPresented: $showingCalendar) {
            CalendarModalView()
        }
        .sheet(isPresented: $showingAddHabit) {
            HabitCreateView(
                viewModel: HabitCreateViewModel(),
                onSave: { _ in showingAddHabit = false },
                onCancel: { showingAddHabit = false }
            )
        }
        .sheet(isPresented: $showingCompletionList) {
            CompletionListView(habits: $habits)
        }
    }
}

struct QuantHabitBlock: View {
    let title: String
    let icon: String
    @Binding var value: Int
    let max: Int
    let color: Color
    let unit: String
    
    // Layout constants
    private enum Layout {
        static let cornerRadius: CGFloat = UIConstants.cornerRadius
        static let borderWidth: CGFloat = UIConstants.borderWidth
        static let iconSize: CGFloat = 32
        static let unifiedButtonWidth: CGFloat = 140
        static let unifiedButtonHeight: CGFloat = 40
        static let buttonCornerRadius: CGFloat = UIConstants.cornerRadius
        static let shadowOffset: CGFloat = 3
        static let verticalSpacing: CGFloat = 6
        static let horizontalSpacing: CGFloat = 12
        static let padding: CGFloat = 12
        static let titleTopPadding: CGFloat = 6
        static let counterBottomPadding: CGFloat = 8
        static let cardHeight: CGFloat = 155
        static let dividerAngle: CGFloat = 15
        static let dividerLength: CGFloat = 24
    }
    
    // Haptic feedback generator
    private let haptics = { 
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        return generator
    }()
    
    // Separate animation states for each button
    @State private var minusScale: CGFloat = 1
    @State private var plusScale: CGFloat = 1
    
    // Add press states for visual feedback
    @State private var isMinusPressed = false
    @State private var isPlusPressed = false
    
    private func handleButtonPress(increment: Bool) {
        withAnimation(.spring(response: 0.3)) {
            if increment && value < max {
                value += 1
                plusScale = 0.95
            } else if !increment && value > 0 {
                value -= 1
                minusScale = 0.95
            }
            
            // Reset the scale after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2)) {
                    if increment {
                        plusScale = 1
                    } else {
                        minusScale = 1
                    }
                }
            }
        }
        haptics.impactOccurred()
    }
    
    var body: some View {
        VStack(spacing: Layout.verticalSpacing) {
            // Title
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.brandBlue)
                .lineLimit(1)
                .padding(.top, Layout.titleTopPadding)
            
            // Icon
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .foregroundColor(.brandBlue)
            
            // Progress Text
            Text("\(value)/\(max) \(unit)")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.brandBlue.opacity(0.8))
            
            // Unified Control Button
            HStack(spacing: 0) {
                // Minus Button Side
                Button {
                    handleButtonPress(increment: false)
                } label: {
                    Text("–")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.brandBlue)
                        .frame(width: Layout.unifiedButtonWidth/2, height: Layout.unifiedButtonHeight)
                        .background(
                            isMinusPressed ? Color.black.opacity(0.1) : Color.clear
                        )
                }
                .scaleEffect(minusScale)
                .pressEvents {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isMinusPressed = true
                    }
                } onRelease: {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isMinusPressed = false
                    }
                }
                
                // Stylized Divider
                Path { path in
                    let startY = (Layout.unifiedButtonHeight - Layout.dividerLength) / 2
                    path.move(to: CGPoint(x: 0, y: startY))
                    path.addLine(to: CGPoint(x: 0, y: startY + Layout.dividerLength))
                }
                .stroke(Color.brandBlue, lineWidth: Layout.borderWidth)
                .rotationEffect(.degrees(Layout.dividerAngle))
                
                // Plus Button Side
                Button {
                    handleButtonPress(increment: true)
                } label: {
                    Text("+")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: Layout.unifiedButtonWidth/2, height: Layout.unifiedButtonHeight)
                        .background(
                            isPlusPressed ? Color.black.opacity(0.1) : Color.clear
                        )
                }
                .scaleEffect(plusScale)
                .pressEvents {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPlusPressed = true
                    }
                } onRelease: {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPlusPressed = false
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: Layout.buttonCornerRadius)
                    .fill(Color.offWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: Layout.buttonCornerRadius)
                            .fill(Color.brandBlue)
                            .mask(
                                HStack(spacing: 0) {
                                    Rectangle().opacity(0)
                                    Rectangle()
                                }
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Layout.buttonCornerRadius)
                    .stroke(Color.brandBlue, lineWidth: Layout.borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: Layout.buttonCornerRadius))
            .shadow(color: Color.brandBlue.opacity(0.1), radius: 0, x: 0, y: Layout.shadowOffset)
            .padding(.bottom, Layout.counterBottomPadding)
        }
        .frame(height: Layout.cardHeight)
        .padding(.horizontal, Layout.padding)
        .background(
            RoundedRectangle(cornerRadius: Layout.cornerRadius)
                .fill(color)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Layout.cornerRadius)
                .stroke(Color.brandBlue.opacity(0.1), lineWidth: Layout.borderWidth)
        )
    }
}

// Add ViewModifier for press events
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    onPress()
                }
                .onEnded { _ in
                    onRelease()
                }
        )
    }
}

// Custom button style for better touch feedback
struct QuantButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .white : .brandBlue)
            .background(
                Group {
                    if configuration.isPressed {
                        // Pressed state: blue fill with white+blue shadows
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.brandBlue)
                            .shadow(color: .white, radius: 0, x: 1.5, y: 1.5)
                            .shadow(color: Color(hex: "#23409A"), radius: 0, x: 3, y: 3)
                    } else {
                        // Normal state: white fill with blue shadow
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.white)
                            .shadow(color: Color(hex: "#23409A"), radius: 0, x: 3, y: 3)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.brandBlue, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}

struct TabBarIcon: View {
    let system: String
    var body: some View {
        Image(systemName: system)
            .resizable()
            .frame(width: 28, height: 28)
            .padding(8)
            .foregroundColor(.brandBlue)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.brandBlue, lineWidth: 2))
    }
}

#Preview {
    HomeView()
}

// MARK: - Home Dashboard Content (for .home tab)
struct HomeDashboardContent: View {
    @State private var selectedDay = 0
    @State private var drinkWater = 8
    @State private var readBook = 15
    @State private var habits = [Habit]()
    let days = ["01\nmon", "02\ntue", "03\nwed", "04\nfri", "05\nfri", "06\nsat", "07\nsun"]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(habits.indices, id: \.self) { i in
                let h = habits[i]
                CompletionCard(
                    icon: h.iconName,
                    title: h.name,
                    isCompleted: isCompletedToday(h.completions),
                    color: h.color.color,
                    onTap: {
                        // Toggle completion
                        withAnimation(.spring(response: 0.3)) {
                            let today = Date()
                            if isCompletedToday(h.completions) {
                                habits[i].completions.removeAll { completion in
                                    Calendar.current.isDate(completion, inSameDayAs: today)
                                }
                            } else {
                                habits[i].completions.append(today)
                            }
                        }
                        // Add haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                )
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

// MARK: - Calendar Modal
struct CalendarModalView: View {
    private let calendar = Calendar.current
    private let daysToShow = 21

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(NSLocalizedString("calendar_overview_title", comment: "Calendar Overview"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                SimpleCalendarGrid(days: daysToShow)
                Spacer()
            }
            .padding()
            .navigationTitle(Text(NSLocalizedString("calendar_title", comment: "Calendar")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("close_button", comment: "Close")) {
                        // Dismiss handled by .sheet
                    }
                }
            }
        }
    }
}

struct SimpleCalendarGrid: View {
    let days: Int
    private let calendar = Calendar.current

    var body: some View {
        let today = calendar.startOfDay(for: Date())
        let dates = (0..<days).map { calendar.date(byAdding: .day, value: -$0, to: today)! }.reversed()
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
            ForEach(dates, id: \.self) { date in
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text("\(calendar.component(.day, from: date))")
                            .font(.caption2)
                            .foregroundColor(.primary)
                    )
                    .accessibilityLabel(String(format: NSLocalizedString("calendar_day_accessibility_label", comment: "Day %d"), calendar.component(.day, from: date)))
            }
        }
    }
}

// MARK: - Calendar View
struct CalendarView: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    
    private var calendarDays: [(date: Date, dayNum: String, dayName: String)] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = weekday - 1
        let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: today)!
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate)!
            let dayNum = calendar.component(.day, from: date)
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            let dayName = dayFormatter.string(from: date).lowercased()
            return (date, String(format: "%02d", dayNum), dayName)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                let availableWidth = geometry.size.width - (Layout.sectionContentPadding * 2)
                let totalSpacing = Layout.calendarItemSpacing * 6 // 6 spaces between 7 items
                let itemWidth = (availableWidth - totalSpacing) / 7
                
                HStack(spacing: Layout.calendarItemSpacing) {
                    ForEach(calendarDays, id: \.0) { day in
                        VStack(spacing: 2) {
                            Text(day.dayNum)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(calendar.isDate(day.date, inSameDayAs: selectedDate) ? .white : .brandBlue)
                            
                            Text(day.dayName)
                                .font(.system(size: 11, weight: .medium))
                                .textCase(.uppercase)
                                .foregroundColor(calendar.isDate(day.date, inSameDayAs: selectedDate) ? .white : .brandBlue)
                        }
                        .frame(width: itemWidth, height: Layout.calendarItemHeight)
                        .background(
                            ZStack {
                                if calendar.isDate(day.date, inSameDayAs: selectedDate) {
                                    RoundedRectangle(cornerRadius: Layout.calendarCornerRadius)
                                        .fill(Color.brandBlue)
                                }
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Layout.calendarCornerRadius)
                                .stroke(Color.brandBlue, lineWidth: UIConstants.borderWidth)
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Layout.sectionContentPadding)
                .padding(.vertical, Layout.calendarVerticalPadding)
            }
            .frame(height: Layout.calendarItemHeight + (Layout.calendarVerticalPadding * 2))
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

// MARK: - Shared Constants
private enum StyleConstants {
    static let cardCornerRadius: CGFloat = UIConstants.cornerRadius
    static let cardBorderWidth: CGFloat = UIConstants.borderWidth
    static let cardShadowOffset: CGFloat = 3
    static let cardIconSize: CGFloat = 24
    static let cardHeight: CGFloat = 54
    static let cardHorizontalPadding: CGFloat = 16
    static let checkboxSize: CGFloat = 28
    static let checkboxCornerRadius: CGFloat = UIConstants.cornerRadius
    static let cardSpacing: CGFloat = 8
    static let completionListPadding: CGFloat = 16
}

// MARK: - Completion Card
struct CompletionCard: View {
    let icon: String
    let title: String
    let isCompleted: Bool
    let color: Color
    var onTap: (() -> Void)? = nil
    
    // Animation states
    @State private var checkmarkScale: CGFloat = 1
    @State private var cardScale: CGFloat = 1
    
    // Haptic feedback generator - lazy initialization
    private let haptics = { 
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        return generator
    }()
    
    private var accessibilityLabel: String {
        let status = isCompleted ? NSLocalizedString("completed", comment: "Habit completed status") 
                                : NSLocalizedString("not_completed", comment: "Habit not completed status")
        return "\(title), \(status)"
    }
    
    private var accessibilityHint: String {
        isCompleted ? NSLocalizedString("double_tap_to_mark_incomplete", comment: "Hint for marking habit incomplete")
                   : NSLocalizedString("double_tap_to_mark_complete", comment: "Hint for marking habit complete")
    }
    
    var body: some View {
        Button(action: {
            // Trigger haptic feedback
            haptics.impactOccurred()
            
            // Animate the card
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                cardScale = 0.95
            }
            
            // Animate the checkmark if becoming completed
            if !isCompleted {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    checkmarkScale = 1.2
                }
            }
            
            // Reset animations after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    cardScale = 1
                    checkmarkScale = 1
                }
            }
            
            onTap?()
        }) {
            HStack(spacing: 16) {
                // Icon without rotation animation
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: StyleConstants.cardIconSize, height: StyleConstants.cardIconSize)
                    .foregroundColor(.brandBlue)
                    .accessibilityHidden(true)
                
                // Title
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.brandBlue)
                    .accessibilityHidden(true)
                
                Spacer()
                
                // Checkbox with completion animation
                ZStack {
                    RoundedRectangle(cornerRadius: StyleConstants.checkboxCornerRadius)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: StyleConstants.checkboxCornerRadius)
                                .stroke(Color.brandBlue, lineWidth: UIConstants.borderWidth)
                        )
                        .frame(width: StyleConstants.checkboxSize, height: StyleConstants.checkboxSize)
                        .shadow(color: Color.brandBlue.opacity(0.1), radius: 0, x: 0, y: StyleConstants.cardShadowOffset)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.brandBlue)
                            .scaleEffect(checkmarkScale)
                    }
                }
                .accessibilityHidden(true)
            }
            .frame(height: StyleConstants.cardHeight)
            .padding(.horizontal, StyleConstants.cardHorizontalPadding)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: StyleConstants.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: StyleConstants.cardCornerRadius)
                    .stroke(Color.brandBlue.opacity(0.1), lineWidth: UIConstants.borderWidth)
            )
            .shadow(color: Color.brandBlue.opacity(0.1), radius: 0, x: 0, y: StyleConstants.cardShadowOffset)
            .scaleEffect(cardScale)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isCompleted ? .isSelected : [])
    }
}

// MARK: - Completion List View Model
final class CompletionListViewModel: ObservableObject {
    @Published var habits: [CoreHabit]
    
    init(habits: [CoreHabit]) {
        self.habits = habits
    }
    
    func toggleHabit(at index: Int) {
        guard habits.indices.contains(index) else { return }
        let today = Date()
        if isCompletedToday(habits[index].completions) {
            habits[index].completions.removeAll { completion in
                Calendar.current.isDate(completion, inSameDayAs: today)
            }
        } else {
            habits[index].completions.append(today)
        }
    }
    
    var completedCount: Int {
        habits.filter { isCompletedToday($0.completions) }.count
    }
    
    var totalCount: Int {
        habits.count
    }
}

// MARK: - Completion List View
struct CompletionListView: View {
    @StateObject private var viewModel: CompletionListViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    init(habits: Binding<[CoreHabit]>) {
        _viewModel = StateObject(wrappedValue: CompletionListViewModel(habits: habits.wrappedValue))
    }
    
    private var completionCount: String {
        String(format: NSLocalizedString("completion_count_format", 
                                       comment: "Format for showing completed/total habits"), 
               viewModel.completedCount, viewModel.totalCount)
    }
    
    private var adaptiveSpacing: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium:
            return StyleConstants.cardSpacing
        case .large, .xLarge:
            return StyleConstants.cardSpacing * 1.2
        default:
            return StyleConstants.cardSpacing * 1.5
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Pull down handle indicator
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.brandBlue.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                    .accessibilityHidden(true)
                
                // Section header with completion count
                HStack {
                    Text(NSLocalizedString("daily_completion_title", 
                                         comment: "Daily completion section title"))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.brandBlue)
                    Spacer()
                    Text(completionCount)
                        .font(.subheadline)
                        .foregroundColor(.brandBlue.opacity(0.8))
                }
                .padding(.horizontal, StyleConstants.completionListPadding)
                .padding(.top, 8)
                
                // Habits list
                ScrollView {
                    LazyVStack(spacing: adaptiveSpacing) {
                        ForEach(viewModel.habits.indices, id: \.self) { i in
                            let h = viewModel.habits[i]
                            CompletionCard(
                                icon: h.iconName,
                                title: h.name,
                                isCompleted: isCompletedToday(h.completions),
                                color: h.color.color,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.toggleHabit(at: i)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, StyleConstants.completionListPadding)
                }
                
                Spacer()
            }
            .background(Color.offWhite)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("done_button", comment: "Done button")) {
                        dismiss()
                    }
                }
            }
        }
    }
} 
