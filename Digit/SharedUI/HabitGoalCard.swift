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

    @State private var showConfetti = false
    @State private var confettiID = UUID()

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
        .overlay(
            Group {
                if showConfetti {
                    ConfettiView()
                        .id(confettiID)
                        .transition(.opacity)
                }
            }
        )
        .onChange(of: percent) { oldPercent, newPercent in
            if oldPercent < 1.0 && newPercent >= 1.0 {
                confettiID = UUID()
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation { showConfetti = false }
                }
            }
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

// Simple confetti animation view
private struct ConfettiView: View {
    @State private var animate = false
    private let confettiCount = 24
    private let colors: [Color] = [
        HabitGridColorScale.color(for: 0.0),
        HabitGridColorScale.color(for: 0.25),
        HabitGridColorScale.color(for: 0.5),
        HabitGridColorScale.color(for: 0.75),
        HabitGridColorScale.color(for: 1.0)
    ]
    private let shapes: [ConfettiShape] = [.circle, .rectangle, .roundedRectangle]
    
    struct ConfettiParticle: Identifiable {
        let id = UUID()
        let color: Color
        let shape: ConfettiShape
        let size: CGFloat
        let xStart: CGFloat
        let xEnd: CGFloat
        let yEnd: CGFloat
        let rotationStart: Angle
        let rotationEnd: Angle
        let opacity: Double
        let duration: Double
        let delay: Double
    }
    
    private func makeParticles(width: CGFloat, height: CGFloat) -> [ConfettiParticle] {
        (0..<confettiCount).map { i in
            let color = colors[i % colors.count].opacity(Double.random(in: 0.5...1.0))
            let shape = shapes.randomElement() ?? .circle
            let size = CGFloat.random(in: 10...18)
            let xStart = CGFloat.random(in: 0...(width - size))
            let xEnd = xStart + CGFloat.random(in: -60...60)
            let yEnd = height + CGFloat.random(in: 40...120)
            let rotationStart = Angle.degrees(Double.random(in: 0...360))
            let rotationEnd = Angle.degrees(Double.random(in: 720...1440))
            let opacity = Double.random(in: 0.7...1.0)
            let duration = Double.random(in: 1.1...1.7)
            let delay = Double(i) * 0.03 + Double.random(in: 0...0.12)
            return ConfettiParticle(
                color: color,
                shape: shape,
                size: size,
                xStart: xStart,
                xEnd: xEnd,
                yEnd: yEnd,
                rotationStart: rotationStart,
                rotationEnd: rotationEnd,
                opacity: opacity,
                duration: duration,
                delay: delay
            )
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let particles = makeParticles(width: geo.size.width, height: geo.size.height)
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(
                        shape: particle.shape,
                        color: particle.color,
                        size: particle.size,
                        rotation: animate ? particle.rotationEnd : particle.rotationStart
                    )
                    .position(x: animate ? particle.xEnd : particle.xStart, y: animate ? particle.yEnd : -particle.size)
                    .opacity(animate ? 0 : particle.opacity)
                    .animation(
                        .easeOut(duration: particle.duration)
                            .delay(particle.delay),
                        value: animate
                    )
                }
            }
            .onAppear { animate = true }
        }
        .allowsHitTesting(false)
    }
}

private enum ConfettiShape {
    case circle, rectangle, roundedRectangle
}

private struct ConfettiPiece: View {
    let shape: ConfettiShape
    let color: Color
    let size: CGFloat
    let rotation: Angle
    var body: some View {
        Group {
            switch shape {
            case .circle:
                Circle()
                    .fill(color)
            case .rectangle:
                Rectangle()
                    .fill(color)
            case .roundedRectangle:
                RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                    .fill(color)
            }
        }
        .frame(width: size, height: size)
        .rotationEffect(rotation)
        .shadow(color: color.opacity(0.18), radius: 1, y: 1)
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