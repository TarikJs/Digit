import SwiftUI

// MARK: - View
struct NewHabitView: View {
    // MARK: - Layout Constants
    private enum Layout {
        static let cardPadding: CGFloat = 20
        static let cardVerticalPadding: CGFloat = 24
        static let buttonHeight: CGFloat = 48
        static let cornerRadius: CGFloat = 12
        static let iconSize: CGFloat = 60
        static let shadowOpacity: CGFloat = 0.08
        static let shadowRadius: CGFloat = 2
        static let shadowY: CGFloat = 1
    }

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var homeViewModel: HomeViewModel
    @StateObject private var habitViewModel: HabitViewModel
    @StateObject private var viewModel = NewHabitViewModel()
    let onDismiss: () -> Void
    var hideCancelButton: Bool = false

    init(onDismiss: @escaping () -> Void, userId: String, homeViewModel: HomeViewModel, hideCancelButton: Bool = false) {
        self.onDismiss = onDismiss
        self.homeViewModel = homeViewModel
        self.hideCancelButton = hideCancelButton
        _habitViewModel = StateObject(wrappedValue: HabitViewModel(habitRepository: HabitRepository(), userId: userId))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.digitBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 0) {
                        // Full-width black header
                        titleAndCancel
                        Divider().background(Color.digitDivider)
                        // Card content
                        VStack(alignment: .leading, spacing: 28) {
                            nameSection
                            Divider().background(Color.digitDivider)
                            goalSection
                                .padding(.vertical, Layout.cardVerticalPadding)
                            Divider().background(Color.digitDivider)
                            scheduleSection
                                .padding(.vertical, Layout.cardVerticalPadding)
                            Divider().background(Color.digitDivider)
                            alertSection
                                .padding(.vertical, Layout.cardVerticalPadding)
                            Divider().background(Color.digitDivider)
                            iconPickerSection
                                .padding(.vertical, Layout.cardVerticalPadding)
                            saveButtonSection
                                .padding(.vertical, Layout.cardVerticalPadding)
                        }
                        .padding(Layout.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.03), radius: 8, y: 2)
                        )
                        .padding(.vertical, Layout.cardVerticalPadding)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: Binding<Bool>(
                get: { habitViewModel.errorMessage != nil },
                set: { _ in habitViewModel.errorMessage = nil }
            )) {
                Alert(title: Text("Error"), message: Text(habitViewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            habitViewModel.onHabitCreated = {
                homeViewModel.selectDate(homeViewModel.selectedDate)
                dismiss()
            }
        }
    }

    // MARK: - Subviews
    private var titleAndCancel: some View {
        VStack(spacing: 0) {
            Color.digitBrand
                .frame(height: 40)
                .shadow(color: Color.black.opacity(0.03), radius: 2, y: 2)
                .overlay(
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.digitAccentRed)
                            .frame(width: 4, height: 24)
                        Text("New Habit")
                            .font(.plusJakartaSans(size: 22, weight: .bold))
                            .foregroundStyle(Color.white)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityLabel("New Habit")
                        Spacer()
                        if !hideCancelButton {
                            Button("Cancel") {
                                onDismiss()
                            }
                            .font(.plusJakartaSans(size: 17, weight: .regular))
                            .foregroundStyle(Color.white)
                            .accessibilityLabel("Cancel")
                        }
                    }
                    .padding(.horizontal, DigitLayout.Padding.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                )
                .overlay(
                    Divider()
                        .background(Color.digitDivider), alignment: .bottom
                )
                .padding(.top, 16)
                .padding(.bottom, 12)
                .zIndex(1)
        }
        .background(Color.digitBrand)
    }
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Habit Name")
                .font(.plusJakartaSans(size: 18, weight: .semibold))
                .foregroundStyle(Color.digitBrand)
            TextField("e.g., Meditate", text: $viewModel.name)
                .font(.plusJakartaSans(size: 17, weight: .regular))
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(Color.digitGrayLight)
                .cornerRadius(10)
                .disableAutocorrection(true)
                .foregroundStyle(Color.digitBrand)
                .accessibilityLabel("Habit Name")
                .onChange(of: viewModel.name) {
                    Task { await viewModel.onNameChanged() }
                }
        }
    }
    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Set a daily goal")
                    .font(.plusJakartaSans(size: 18, weight: .semibold))
                    .foregroundStyle(Color.digitBrand)
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(viewModel.goalPerDay)")
                        .font(.plusJakartaSans(size: 20, weight: .bold))
                        .foregroundStyle(Color.digitBrand)
                    Text(viewModel.selectedUnit ?? "times")
                        .font(.plusJakartaSans(size: 20, weight: viewModel.selectedUnit == nil ? .regular : .bold))
                        .foregroundStyle(viewModel.selectedUnit == nil ? Color.digitBrand.opacity(0.5) : Color.digitBrand)
                }
            }
            HStack(spacing: 0) {
                goalButton(isIncrement: false)
                goalButton(isIncrement: true)
            }
            .background(Color.digitGrayLight)
            .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous))
        }
    }

    private func goalButton(isIncrement: Bool) -> some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            if isIncrement {
                if viewModel.goalPerDay < viewModel.maxGoal {
                    viewModel.goalPerDay += 1
                }
            } else {
                if viewModel.goalPerDay > viewModel.minGoal {
                    viewModel.goalPerDay -= 1
                }
            }
        }) {
            ZStack {
                isIncrement ? Color.digitAccentRed : Color.white
                Image(systemName: isIncrement ? "plus" : "minus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isIncrement ? Color.white : Color.digitAccentRed)
                if !isIncrement {
                    RoundedCorners(tl: Layout.cornerRadius, tr: 0, bl: Layout.cornerRadius, br: 0)
                        .stroke(Color.digitAccentRed, lineWidth: 2.5)
                }
            }
            .frame(maxWidth: .infinity, minHeight: Layout.buttonHeight, maxHeight: Layout.buttonHeight)
            .clipShape(RoundedCorners(
                tl: isIncrement ? 0 : Layout.cornerRadius,
                tr: isIncrement ? Layout.cornerRadius : 0,
                bl: isIncrement ? 0 : Layout.cornerRadius,
                br: isIncrement ? Layout.cornerRadius : 0
            ))
            .shadow(
                color: Color.black.opacity(Layout.shadowOpacity),
                radius: Layout.shadowRadius,
                y: Layout.shadowY
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(isIncrement ? "Increase goal" : "Decrease goal")
        .opacity(isIncrement ? 
            (viewModel.goalPerDay < viewModel.maxGoal ? 1.0 : 0.5) :
            (viewModel.goalPerDay > viewModel.minGoal ? 1.0 : 0.5)
        )
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Schedule")
                .font(.plusJakartaSans(size: 18, weight: .semibold))
                .foregroundStyle(Color.digitBrand)
            datePickersSection
            repeatFrequencySection
            if viewModel.repeatFrequency == .custom {
                customWeekdayPicker
            }
        }
    }

    // MARK: - Date Pickers Section
    private var datePickersSection: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 16) {
                Text("Start Date")
                    .font(.plusJakartaSans(size: 16, weight: .regular))
                    .foregroundStyle(Color.digitBrand)
                Spacer()
                DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                    .labelsHidden()
                    .font(.plusJakartaSans(size: 16, weight: .regular))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .foregroundStyle(Color.digitBrand)
                    .tint(Color.digitAccentRed)
            }
            HStack(alignment: .center, spacing: 16) {
                Text("End Date")
                    .font(.plusJakartaSans(size: 16, weight: .regular))
                    .foregroundStyle(Color.digitBrand)
                Spacer()
                DatePicker("End Date", selection: Binding(
                    get: { viewModel.endDate ?? viewModel.startDate },
                    set: { viewModel.endDate = $0 }
                ), in: viewModel.startDate..., displayedComponents: .date)
                    .labelsHidden()
                    .font(.plusJakartaSans(size: 16, weight: .regular))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(10)
                    .foregroundStyle(Color.digitBrand)
                    .tint(Color.digitAccentRed)
                    .accessibilityLabel("End Date")
                    .onChange(of: viewModel.endDate) { _, newValue in
                        if let end = newValue, end < viewModel.startDate {
                            viewModel.endDate = viewModel.startDate
                        }
                    }
            }
        }
    }

    // MARK: - Repeat Frequency Section
    private var repeatFrequencySection: some View {
        HStack(spacing: 8) {
            ForEach(NewHabitViewModel.RepeatFrequency.allCases) { freq in
                let isSelected = viewModel.repeatFrequency == freq
                Button(action: { withAnimation(.easeInOut(duration: 0.15)) { viewModel.repeatFrequency = freq } }) {
                    Text(freq.rawValue)
                        .font(.plusJakartaSans(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.white : Color.digitBrand)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.digitAccentRed : Color.digitGrayLight)
                        .cornerRadius(10)
                        .shadow(color: isSelected ? Color.digitAccentRed.opacity(0.10) : .clear, radius: 2, y: 1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(freq.rawValue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
    }

    // MARK: - Custom Weekday Picker
    private var customWeekdayPicker: some View {
        let daySymbols = Calendar.current.shortWeekdaySymbols
        return GeometryReader { geometry in
            let buttonCount = 7
            let totalSpacing: CGFloat = 6 * CGFloat(buttonCount - 1)
            let buttonWidth = (geometry.size.width - totalSpacing) / CGFloat(buttonCount)
            HStack(spacing: 6) {
                ForEach(Array(1...7), id: \.self) { weekday in
                    let symbol = daySymbols[weekday - 1]
                    let isSelected = viewModel.selectedWeekdays.contains(weekday)
                    Button(action: {
                        if isSelected {
                            viewModel.selectedWeekdays.remove(weekday)
                        } else {
                            viewModel.selectedWeekdays.insert(weekday)
                        }
                    }) {
                        Text(symbol)
                            .font(.plusJakartaSans(size: 15, weight: .semibold))
                            .frame(width: buttonWidth, height: 36)
                            .background(isSelected ? Color.digitAccentRed : Color.digitGrayLight)
                            .foregroundStyle(isSelected ? Color.white : Color.digitBrand)
                            .cornerRadius(8)
                            .shadow(color: isSelected ? Color.digitAccentRed.opacity(0.10) : .clear, radius: 1, y: 1)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(symbol)
                }
            }
        }
        .frame(height: 36)
    }
    private var alertSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $viewModel.alertEnabled) {
                Text("Enable alert/reminder")
                    .font(.plusJakartaSans(size: 18, weight: .semibold))
                    .foregroundStyle(Color.digitBrand)
            }
            .toggleStyle(BrandSwitchToggleStyle())
            .accessibilityLabel("Enable alert/reminder")
            if viewModel.alertEnabled {
                DatePicker("Alert Time", selection: $viewModel.alertTime, displayedComponents: .hourAndMinute)
                    .font(.plusJakartaSans(size: 16, weight: .regular))
                    .foregroundStyle(Color.digitBrand)
                    .tint(Color.digitAccentRed)
                    .accessibilityLabel("Alert Time")
            }
        }
    }
    private var iconPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose an icon")
                .font(.plusJakartaSans(size: 18, weight: .semibold))
                .foregroundStyle(Color.digitBrand)
            // Curated, valid SF Symbols for habits (iOS 18+)
            let allIcons: [NewHabitViewModel.Icon] = [
                // Additional Workout & Meditation Icons
                .init(id: "figure.mind.and.body", systemName: "figure.mind.and.body"),
                .init(id: "figure.yoga", systemName: "figure.yoga"),
                .init(id: "figure.strengthtraining.functional", systemName: "figure.strengthtraining.functional"),
                .init(id: "figure.open.water.swim", systemName: "figure.open.water.swim"),
                .init(id: "dumbbell.fill", systemName: "dumbbell.fill"),
                .init(id: "lungs.fill", systemName: "lungs.fill"),
                .init(id: "waveform", systemName: "waveform"),
                // Physical & Movement
                .init(id: "figure.walk", systemName: "figure.walk"),
                .init(id: "figure.run", systemName: "figure.run"),
                .init(id: "bicycle", systemName: "bicycle"),
                .init(id: "flame.fill", systemName: "flame.fill"),
                .init(id: "bolt.heart.fill", systemName: "bolt.heart.fill"),
                .init(id: "figure.strengthtraining.traditional", systemName: "figure.strengthtraining.traditional"),

                // Mindfulness & Focus
                .init(id: "brain.head.profile", systemName: "brain.head.profile"),
                .init(id: "sparkles", systemName: "sparkles"),
                .init(id: "face.smiling", systemName: "face.smiling"),
                .init(id: "sun.max.fill", systemName: "sun.max.fill"),
                .init(id: "moon.stars.fill", systemName: "moon.stars.fill"),
                .init(id: "waveform.path.ecg", systemName: "waveform.path.ecg"),

                // Nutrition & Health
                .init(id: "leaf.fill", systemName: "leaf.fill"),
                .init(id: "waterbottle.fill", systemName: "waterbottle.fill"),
                .init(id: "drop.fill", systemName: "drop.fill"),
                .init(id: "carrot.fill", systemName: "carrot.fill"),
                .init(id: "fork.knife", systemName: "fork.knife"),
                .init(id: "cup.and.saucer.fill", systemName: "cup.and.saucer.fill"),

                // Learning & Productivity
                .init(id: "book.fill", systemName: "book.fill"),
                .init(id: "pencil", systemName: "pencil"),
                .init(id: "graduationcap.fill", systemName: "graduationcap.fill"),
                .init(id: "lightbulb.fill", systemName: "lightbulb.fill"),
                .init(id: "calendar", systemName: "calendar"),
                .init(id: "checkmark.circle.fill", systemName: "checkmark.circle.fill"),

                // Rest & Sleep
                .init(id: "bed.double.fill", systemName: "bed.double.fill"),
                .init(id: "zzz", systemName: "zzz"),
                .init(id: "alarm.fill", systemName: "alarm.fill"),
                .init(id: "moon.fill", systemName: "moon.fill"),
                .init(id: "eye.slash.fill", systemName: "eye.slash.fill"),
                .init(id: "stopwatch.fill", systemName: "stopwatch.fill"),

                // Self-care & Wellness
                .init(id: "hand.raised.fill", systemName: "hand.raised.fill"),
                .init(id: "hands.sparkles.fill", systemName: "hands.sparkles.fill"),
                .init(id: "shower.fill", systemName: "shower.fill"),
                .init(id: "tshirt.fill", systemName: "tshirt.fill"),
                .init(id: "face.smiling.fill", systemName: "face.smiling.fill"),
                .init(id: "comb.fill", systemName: "comb.fill"),
                .init(id: "bandage.fill", systemName: "bandage.fill"),
                .init(id: "cross.case.fill", systemName: "cross.case.fill"),

                // Creative & Other Hobbies
                .init(id: "figure.dance", systemName: "figure.dance"),
                .init(id: "paintpalette.fill", systemName: "paintpalette.fill"),
                .init(id: "leaf.arrow.circlepath", systemName: "leaf.arrow.circlepath"),
                .init(id: "binoculars.fill", systemName: "binoculars.fill"),
                .init(id: "theatermasks.fill", systemName: "theatermasks.fill")
            ]
            let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(allIcons) { icon in
                        let isSelected = viewModel.selectedIcon == icon
                        Button(action: { viewModel.selectedIcon = icon }) {
                            ZStack {
                                (isSelected ? Color.digitAccentRed : Color.digitGrayLight)
                                    .cornerRadius(16)
                                Image(systemName: icon.systemName)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(isSelected ? Color.white : Color.digitBrand)
                                    .padding(14)
                            }
                            .frame(width: 60, height: 60)
                            .shadow(color: isSelected ? Color.digitAccentRed.opacity(0.10) : .clear, radius: 2, y: 1)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(icon.systemName)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    private var saveButtonSection: some View {
        Button(action: {
            Task {
                await viewModel.saveHabit(using: habitViewModel)
            }
        }) {
            HStack {
                if viewModel.isLoading || viewModel.isSaving {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                Text("Save Habit")
                    .font(.plusJakartaSans(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canSave ? Color.digitAccentRed : Color.digitAccentRed.opacity(0.4))
            .cornerRadius(Layout.cornerRadius)
            .shadow(
                color: Color.black.opacity(Layout.shadowOpacity),
                radius: Layout.shadowRadius,
                y: Layout.shadowY
            )
        }
        .disabled(!viewModel.canSave || viewModel.isLoading || viewModel.isSaving)
        .padding(.top, 8)
        .onAppear {
            viewModel.onSave = { success in
                if success {
                    homeViewModel.selectDate(homeViewModel.selectedDate)
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Brand Switch Toggle Style
struct BrandSwitchToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Toggle(configuration)
            .tint(Color.digitAccentRed)
    }
}

// MARK: - Custom RoundedCorners Shape
struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.size.width
        let h = rect.size.height
        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()
        return path
    }
}

#if DEBUG
private class MockHabitService: HabitServiceProtocol {
    func fetchHabits() async throws -> [Habit] { [] }
    func addHabit(_ habit: Habit) async throws {}
    func updateHabit(_ habit: Habit) async throws {}
    func deleteHabit(id: UUID) async throws {}
    func getCurrentHabit(for userId: String) async throws -> Habit? { nil }
}
#Preview {
    NewHabitView(
        onDismiss: {},
        userId: "preview-user-id",
        homeViewModel: HomeViewModel(habitRepository: HabitRepository(), progressRepository: ProgressRepository(), userId: UUID())
    )
}
#endif 
