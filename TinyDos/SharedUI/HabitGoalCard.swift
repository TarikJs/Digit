import SwiftUI
// If needed, import the module or file where HabitGridColorScale is defined
// import HabitGridColorScale

struct HabitGoalCard: View {
    let icon: String
    let title: String
    let progress: Int
    let goal: Int
    let unit: String?
    let tag: String?
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let buttonsEnabled: Bool
    let isEditMode: Bool
    let onDelete: (() -> Void)?
    let onTap: (() -> Void)?

    // State for swipe gesture
    @State private var offsetX: CGFloat = 0
    @State private var showDelete: Bool = false
    private let swipeThreshold: CGFloat = 60
    private let deleteButtonWidth: CGFloat = 72

    private var percent: Double {
        guard goal > 0 else { return 0.0 }
        return min(Double(progress) / Double(goal), 1.0)
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            if let onDelete = onDelete {
                // Delete button (behind the card, revealed on swipe)
                Button(action: {
                    print("[DEBUG] Delete button tapped for card: \(title)")
                    withAnimation { offsetX = 0 }
                    onDelete()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.digitAccentRed)
                        Image(systemName: "trash")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                    .accessibilityLabel("Delete habit: \(title)")
                }
                .frame(width: deleteButtonWidth, height: 80)
                .padding(.trailing, 2)
                .opacity(offsetX != 0 ? 1 : 0)
                .zIndex(0)
            }
            HStack(spacing: 0) {
                // Red accent bar
                Rectangle()
                    .fill(Color.digitAccentRed)
                    .frame(width: 5)
                HStack(spacing: 16) {
                    CompletionRing(percent: percent, icon: icon, isComplete: percent >= 1.0)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.plusJakartaSans(size: 18, weight: .semibold))
                            .foregroundStyle(Color.digitBrand)
                            .lineLimit(2)
                        if let tag = tag, !tag.isEmpty {
                            Text(tag)
                                .font(.plusJakartaSans(size: 12, weight: .bold))
                                .foregroundColor(Color.digitBrand)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.digitBrand.opacity(0.08))
                                .cornerRadius(8)
                        }
                        Text("\(progress)/\(goal)\(unitLabel)")
                            .font(.plusJakartaSans(size: 14, weight: .medium))
                            .foregroundStyle(Color.digitAccentRed)
                    }
                    Spacer()
                    if percent >= 1.0 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(Color.digitAccentRed)
                            .transition(.scale)
                    } else {
                        HStack(spacing: 8) {
                            Button(action: {
                                if buttonsEnabled {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                                onIncrement()
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(buttonsEnabled ? Color.digitAccentRed : Color.digitGrayLight)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(buttonsEnabled ? Color.digitAccentRed : Color.digitGrayLight, lineWidth: 1.5)
                                    )
                            }
                            .disabled(!buttonsEnabled)
                            // Trash button (edit mode only)
                            if let onDelete = onDelete, isEditMode {
                                Button(action: {
                                    onDelete()
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(Color.white)
                                        .frame(width: 44, height: 44)
                                        .background(Color.digitAccentRed)
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                        .shadow(color: Color.black.opacity(0.08), radius: 2, y: 1)
                                }
                                .accessibilityLabel("Delete goal")
                            }
                        }
                    }
                }
                .padding(14)
                .frame(height: 80)
                .background(
                    RoundedCorner(radius: 10, corners: [.topRight, .bottomRight])
                        .fill(Color.white)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
            }
            .padding(0)
            .frame(height: 80)
            .background(
                RoundedCorner(radius: 10, corners: [.topRight, .bottomRight])
                    .fill(Color.white)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
            .contentShape(Rectangle())
            .zIndex(1)
            .onTapGesture {
                if let onTap = onTap {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onTap()
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
        .offset(x: offsetX)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onChanged { value in
                    if onDelete != nil {
                        let horizontal = value.translation.width
                        let vertical = value.translation.height
                        if abs(horizontal) > abs(vertical) {
                            print("[DEBUG] Drag started for card: \(title)")
                            let newOffset = max(-deleteButtonWidth, min(0, horizontal))
                            offsetX = newOffset
                            print("[DEBUG] Drag changed for card: \(title), offsetX: \(offsetX)")
                        }
                    }
                }
                .onEnded { value in
                    if onDelete != nil {
                        let horizontal = value.translation.width
                        let vertical = value.translation.height
                        print("[DEBUG] Drag ended for card: \(title), translation: (h: \(horizontal), v: \(vertical))")
                        if abs(horizontal) > abs(vertical) && horizontal < -swipeThreshold {
                            withAnimation { offsetX = -deleteButtonWidth }
                            print("[DEBUG] Swipe threshold passed for card: \(title), showing delete")
                        } else {
                            withAnimation { offsetX = 0 }
                            print("[DEBUG] Swipe threshold NOT passed for card: \(title), resetting")
                        }
                    }
                }
        )
    }

    private var unitLabel: String {
        guard let unit, !unit.isEmpty else { return "" }
        return " \(unit)"
    }

    init(
        icon: String,
        title: String,
        progress: Int,
        goal: Int,
        unit: String? = nil,
        tag: String? = nil,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void,
        buttonsEnabled: Bool,
        isEditMode: Bool,
        onDelete: (() -> Void)? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.progress = progress
        self.goal = goal
        self.unit = unit
        self.tag = tag
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
        self.buttonsEnabled = buttonsEnabled
        self.isEditMode = isEditMode
        self.onDelete = onDelete
        self.onTap = onTap
    }
}

private struct CompletionRing: View {
    let percent: Double // 0.0 to 1.0
    let icon: String
    let isComplete: Bool
    private let size: CGFloat = 44
    private let lineWidth: CGFloat = 5
    
    private var progressColor: Color {
        if percent >= 1.0 {
            return Color.digitAccentRed
        } else if percent > 0 {
            return Color.digitBrand
        } else {
            return Color.digitGrayLight
        }
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.digitGrayLight.opacity(0.3), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: percent)
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(progressColor)
        }
        .shadow(color: Color.black.opacity(0.03), radius: 2, y: 1)
    }
}

// Add this extension for corner radius on specific corners
private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
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

// Helper for conditional modifier with optional closure
private extension View {
    @ViewBuilder func ifLet<T>(_ value: T?, transform: (Self, T) -> some View) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}

#if DEBUG
#Preview {
    HabitGoalCard(
        icon: "figure.walk",
        title: "Walk 10,000 steps",
        progress: 3,
        goal: 7,
        unit: "steps",
        tag: "Daily",
        onIncrement: {},
        onDecrement: {},
        buttonsEnabled: true,
        isEditMode: false,
        onDelete: nil,
        onTap: nil
    )
    .padding()
    .background(Color.digitGrayLight)
}
#endif 