import SwiftUI
// If needed, import the module or file where HabitGridColorScale is defined
// import HabitGridColorScale

struct HabitGoalCard: View {
    let icon: String
    let title: String
    let progress: Int
    let goal: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    private var percent: Double {
        guard goal > 0 else { return 0.0 }
        return min(Double(progress) / Double(goal), 1.0)
    }

    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                CompletionRing(percent: percent, icon: icon, isComplete: percent >= 1.0)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.digitBrand)
                        .lineLimit(2)
                    Text("\(progress)/\(goal)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.digitBrand.opacity(0.7))
                }
                Spacer()
                if percent >= 1.0 {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(HabitGridColorScale.color(for: 0.5))
                        .transition(.scale)
                } else {
                    HStack(spacing: 8) {
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            onDecrement()
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.digitBrand)
                                .frame(width: 36, height: 36)
                                .background(Color.digitBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.digitBrand, lineWidth: 1.5)
                                )
                                .shadow(color: Color.black.opacity(0.04), radius: 1, y: 1)
                        }
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            onIncrement()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.digitBrand)
                                .frame(width: 36, height: 36)
                                .background(Color.digitBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.digitBrand, lineWidth: 1.5)
                                )
                                .shadow(color: Color.black.opacity(0.04), radius: 1, y: 1)
                        }
                    }
                }
            }
            .padding(16)
            .frame(height: 92)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.digitBackground)
                    .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.digitBrand, lineWidth: 1.1)
            )
            .frame(maxWidth: .infinity)
        }
    }
}

private struct CompletionRing: View {
    let percent: Double // 0.0 to 1.0
    let icon: String
    let isComplete: Bool
    private let size: CGFloat = 44
    private let lineWidth: CGFloat = 5
    var body: some View {
        ZStack {
            if isComplete {
                Circle()
                    .fill(HabitGridColorScale.color(for: 0.5).opacity(0.15))
                    .frame(width: size, height: size)
            }
            Circle()
                .stroke(Color.digitGrayLight.opacity(0.25), lineWidth: lineWidth)
                .frame(width: size, height: size)
            Circle()
                .trim(from: 0, to: percent)
                .stroke(
                    HabitGridColorScale.color(for: 0.5),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
            if isComplete {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.digitBrand)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.digitBrand)
            }
        }
        .shadow(color: Color.black.opacity(0.03), radius: 2, y: 1)
    }
}

#if DEBUG
#Preview {
    HabitGoalCard(
        icon: "figure.walk",
        title: "Walk 10,000 steps",
        progress: 3,
        goal: 7,
        onIncrement: {},
        onDecrement: {}
    )
    .padding()
    .background(Color.digitGrayLight)
}
#endif 