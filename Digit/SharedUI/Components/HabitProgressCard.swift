import SwiftUI

public struct HabitProgressCard: View {
    public let title: String
    public let icon: String
    public let value: Int
    public let max: Int
    public let unit: String
    public let color: Color
    public let onIncrement: () -> Void
    public let onDecrement: () -> Void
    
    public init(title: String = "Habit Name", icon: String = "star.fill", value: Int = 0, max: Int = 10, unit: String = "times", color: Color = .accentColor, onIncrement: @escaping () -> Void = {}, onDecrement: @escaping () -> Void = {}) {
        self.title = title
        self.icon = icon
        self.value = value
        self.max = max
        self.unit = unit
        self.color = color
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }
    
    private enum Layout {
        static let cornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 16
        static let cardSpacing: CGFloat = 10
        static let iconSize: CGFloat = 38
        static let buttonHeight: CGFloat = 48
        static let buttonCornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 6
        static let buttonFont: Font = .system(size: 28, weight: .bold)
    }
    
    public var body: some View {
        VStack(spacing: Layout.cardSpacing) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.brandBlue)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 6)
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .foregroundColor(.brandBlue)
            Text("\(value)/\(max) \(unit)")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.brandBlue)
                .frame(maxWidth: .infinity, alignment: .center)
            ZStack {
                // Pill background
                RoundedRectangle(cornerRadius: Layout.buttonCornerRadius, style: .continuous)
                    .fill(Color.white)
                    .frame(height: Layout.buttonHeight)
                HStack(spacing: 0) {
                    Button(action: onDecrement) {
                        Text("–")
                            .font(Layout.buttonFont)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(.brandBlue)
                            .background(
                                Color.white
                                    .clipShape(RoundedCorners(tl: Layout.buttonCornerRadius, bl: Layout.buttonCornerRadius))
                            )
                    }
                    .clipShape(RoundedCorners(tl: Layout.buttonCornerRadius, bl: Layout.buttonCornerRadius))
                    Button(action: onIncrement) {
                        Text("+")
                            .font(Layout.buttonFont)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(.white)
                            .background(
                                Color.brandBlue
                                    .clipShape(RoundedCorners(tr: Layout.buttonCornerRadius, br: Layout.buttonCornerRadius))
                            )
                    }
                    .clipShape(RoundedCorners(tr: Layout.buttonCornerRadius, br: Layout.buttonCornerRadius))
                }
                .frame(height: Layout.buttonHeight)
            }
            .frame(height: Layout.buttonHeight)
            .padding(.bottom, 2)
            .shadow(color: Color.brandBlue.opacity(0.10), radius: 2, x: 0, y: 2)
        }
        .padding(Layout.cardPadding)
        .background(color)
        .cornerRadius(Layout.cornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: Layout.shadowRadius, x: 0, y: 2)
    }
}

// Helper for custom corner rounding
private struct RoundedCorners: Shape {
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

#Preview {
    HabitProgressCard(
        title: "Drink water",
        icon: "drop.fill",
        value: 1,
        max: 10,
        unit: "glasses",
        color: Color(hex: "#E6FF5B")
    )
    .frame(width: 180)
    .padding()
    .background(Color(.systemGroupedBackground))
} 