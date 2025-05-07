import SwiftUI

public struct HabitTaskCard: View {
    public let title: String
    public let icon: String
    public let color: Color
    public let isChecked: Bool
    public let onTap: (() -> Void)?
    
    public init(title: String = "Habit Name", icon: String = "star.fill", color: Color = .accentColor, isChecked: Bool = false, onTap: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isChecked = isChecked
        self.onTap = onTap
    }
    
    private enum StyleConstants {
        static let cardCornerRadius: CGFloat = 7
        static let cardBorderWidth: CGFloat = 1.5
        static let cardShadowOffset: CGFloat = 3
        static let cardIconSize: CGFloat = 24
        static let cardHeight: CGFloat = 54
        static let cardHorizontalPadding: CGFloat = 16
        static let checkboxSize: CGFloat = 28
        static let checkboxCornerRadius: CGFloat = 7
    }
    
    @State private var checkmarkScale: CGFloat = 1
    @State private var cardScale: CGFloat = 1
    
    public var body: some View {
        Button(action: {
            // Animate the card and checkmark
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                cardScale = 0.95
                if isChecked {
                    checkmarkScale = 1.2
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    cardScale = 1
                    checkmarkScale = 1
                }
            }
            onTap?()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: StyleConstants.cardIconSize, height: StyleConstants.cardIconSize)
                    .foregroundColor(.brandBlue)
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.brandBlue)
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: StyleConstants.checkboxCornerRadius)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: StyleConstants.checkboxCornerRadius)
                                .stroke(Color.brandBlue, lineWidth: StyleConstants.cardBorderWidth)
                        )
                        .frame(width: StyleConstants.checkboxSize, height: StyleConstants.checkboxSize)
                        .shadow(color: Color.brandBlue.opacity(0.1), radius: 0, x: 0, y: StyleConstants.cardShadowOffset)
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.brandBlue)
                            .scaleEffect(checkmarkScale)
                    }
                }
            }
            .frame(height: StyleConstants.cardHeight)
            .padding(.horizontal, StyleConstants.cardHorizontalPadding)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: StyleConstants.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: StyleConstants.cardCornerRadius)
                    .stroke(Color.brandBlue.opacity(0.1), lineWidth: StyleConstants.cardBorderWidth)
            )
            .shadow(color: Color.brandBlue.opacity(0.1), radius: 0, x: 0, y: StyleConstants.cardShadowOffset)
            .scaleEffect(cardScale)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 12) {
        HabitTaskCard(title: "Work out", icon: "dumbbell.fill", color: Color(hex: "#E6FF5B"), isChecked: false)
        HabitTaskCard(title: "Meditation 30 min", icon: "leaf.fill", color: Color(hex: "#F3D6FF"), isChecked: true)
        HabitTaskCard(title: "No cigarettes", icon: "xmark.circle.fill", color: Color(hex: "#E6FF5B"), isChecked: true)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
} 