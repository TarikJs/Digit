import SwiftUI

// MARK: - View
struct NewHabitView: View {
    // MARK: - Padding Constants
    private static let horizontalPadding: CGFloat = 16
    private static let verticalPadding: CGFloat = 8
    private static let cardPadding: CGFloat = 20
    private static let cardVerticalPadding: CGFloat = 24

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
        _habitViewModel = StateObject(wrappedValue: HabitViewModel(habitService: HabitService(), userId: userId))
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
                            descriptionSection
                            nameSection
                            Divider().background(Color.digitDivider)
                            goalSection
                                .padding(.vertical, Self.verticalPadding)
                            Divider().background(Color.digitDivider)
                            scheduleSection
                                .padding(.vertical, Self.verticalPadding)
                            Divider().background(Color.digitDivider)
                            alertSection
                                .padding(.vertical, Self.verticalPadding)
                            Divider().background(Color.digitDivider)
                            iconPickerSection
                                .padding(.vertical, Self.verticalPadding)
                            saveButtonSection
                                .padding(.vertical, Self.verticalPadding)
                        }
                        .padding(Self.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.03), radius: 8, y: 2)
                        )
                        .padding(.vertical, Self.cardVerticalPadding)
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
        HStack {
            Text("New Habit")
                .font(.digitTitle2)
                .foregroundStyle(Color.white)
            Spacer()
            if !hideCancelButton {
            Button("Cancel") {
                onDismiss()
            }
            .font(.digitBody)
            .foregroundStyle(Color.white)
            .accessibilityLabel("Cancel")
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, Self.horizontalPadding)
        .frame(maxWidth: .infinity)
        .background(Color.digitBrand.edgesIgnoringSafeArea(.top))
    }
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Habit Name")
                .font(.digitHeadline)
                .foregroundStyle(Color.digitBrand)
            TextField("e.g., Meditate", text: $viewModel.name)
                .font(.digitBody)
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.digitBrand, lineWidth: 1.2)
                )
                .foregroundStyle(Color.digitBrand)
                .accessibilityLabel("Habit Name")
        }
    }
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.digitHeadline)
                .foregroundStyle(Color.digitBrand)
            TextField("Optional", text: $viewModel.description)
                .font(.digitBody)
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.digitBrand, lineWidth: 1.2)
                )
                .foregroundStyle(Color.digitBrand)
                .accessibilityLabel("Description")
        }
    }
    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Set a daily goal")
                    .font(.digitHeadline)
                    .foregroundStyle(Color.digitBrand)
                Spacer()
                Text("\(viewModel.goalPerDay)")
                    .fontWeight(.semibold)
                    .font(.digitTitle2)
                    .foregroundStyle(Color.digitBrand)
            }
            HStack(spacing: 0) {
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    if viewModel.goalPerDay > viewModel.minGoal {
                        viewModel.goalPerDay -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.digitBrand)
                        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                        .background(Color.white)
                        .overlay(
                            RoundedCorners(tl: 12, tr: 0, bl: 12, br: 0)
                                .stroke(Color.digitBrand, lineWidth: 2)
                        )
                        .clipShape(RoundedCorners(tl: 12, tr: 0, bl: 12, br: 0))
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Decrease goal")
                .opacity(viewModel.goalPerDay > viewModel.minGoal ? 1.0 : 0.5)
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    if viewModel.goalPerDay < viewModel.maxGoal {
                        viewModel.goalPerDay += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                        .background(Color.digitBrand)
                        .clipShape(RoundedCorners(tl: 0, tr: 12, bl: 0, br: 12))
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Increase goal")
                .opacity(viewModel.goalPerDay < viewModel.maxGoal ? 1.0 : 0.5)
            }
            .background(Color.digitGrayLight)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Schedule")
                .font(.digitHeadline)
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
                    .font(.digitBody)
                    .foregroundStyle(Color.digitBrand)
                Spacer()
                DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                    .labelsHidden()
                    .font(.digitBody)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(10)
                    .foregroundStyle(Color.digitBrand)
                    .tint(Color.digitProgressGreen4)
            }
            HStack(alignment: .center, spacing: 16) {
                Text("End Date")
                    .font(.digitBody)
                    .foregroundStyle(Color.digitBrand)
                Spacer()
                DatePicker("End Date", selection: Binding(
                    get: { viewModel.endDate ?? viewModel.startDate },
                    set: { viewModel.endDate = $0 }
                ), in: viewModel.startDate..., displayedComponents: .date)
                    .labelsHidden()
                    .font(.digitBody)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(10)
                    .foregroundStyle(Color.digitBrand)
                    .tint(Color.digitProgressGreen4)
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
                Button(action: { viewModel.repeatFrequency = freq }) {
                    Text(freq.rawValue)
                        .font(.digitBody)
                        .fontWeight(viewModel.repeatFrequency == freq ? .bold : .regular)
                        .foregroundStyle(viewModel.repeatFrequency == freq ? Color.white : Color.digitBrand)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(viewModel.repeatFrequency == freq ? Color.digitBrand : Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.digitBrand, lineWidth: 1.2)
                        )
                }
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
                    Button(action: {
                        if viewModel.selectedWeekdays.contains(weekday) {
                            viewModel.selectedWeekdays.remove(weekday)
                        } else {
                            viewModel.selectedWeekdays.insert(weekday)
                        }
                    }) {
                        Text(symbol)
                            .font(.digitBody)
                            .fontWeight(.semibold)
                            .frame(width: buttonWidth, height: 36)
                            .background(viewModel.selectedWeekdays.contains(weekday) ? Color.digitBrand : Color.white)
                            .foregroundStyle(viewModel.selectedWeekdays.contains(weekday) ? Color.white : Color.digitBrand)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.digitBrand, lineWidth: 1.2)
                            )
                    }
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
                    .font(.digitHeadline)
                    .foregroundStyle(Color.digitBrand)
            }
            .toggleStyle(BrandSwitchToggleStyle())
            .accessibilityLabel("Enable alert/reminder")
            if viewModel.alertEnabled {
                DatePicker("Alert Time", selection: $viewModel.alertTime, displayedComponents: .hourAndMinute)
                    .font(.digitBody)
                    .foregroundStyle(Color.digitBrand)
                    .accessibilityLabel("Alert Time")
            }
        }
    }
    private var iconPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose an icon")
                .font(.digitHeadline)
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
                        Button(action: { viewModel.selectedIcon = icon }) {
                            ZStack {
                                (viewModel.selectedIcon == icon ? Color.digitBrand : Color.white)
                                    .cornerRadius(16)
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.digitBrand, lineWidth: 2)
                                Image(systemName: icon.systemName)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(viewModel.selectedIcon == icon ? Color.white : Color.digitBrand)
                                    .padding(14)
                            }
                            .frame(width: 60, height: 60)
                        }
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
                    .font(.digitHeadline)
                    .foregroundStyle(Color.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canSave ? Color.digitBrand : Color.digitBrand.opacity(0.4))
            .cornerRadius(14)
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

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

// MARK: - Brand Switch Toggle Style
struct BrandSwitchToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Toggle(configuration)
            .tint(Color.digitBrand)
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
        homeViewModel: HomeViewModel(habitService: MockHabitService(), progressService: HabitProgressService(), userId: UUID())
    )
}
#endif 
