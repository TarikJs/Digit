import SwiftUI

public struct DigitHeaderView: View {
    let name: String
    var topPadding: CGFloat
    var bottomPadding: CGFloat
    let onCalendarTap: (() -> Void)?
    // let onPlusTap: (() -> Void)?

    public init(name: String = "Welcome!", topPadding: CGFloat = 16, bottomPadding: CGFloat = 16, onCalendarTap: (() -> Void)? = nil) {
        self.name = name
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        self.onCalendarTap = onCalendarTap
    }

    public var body: some View {
        print("[DEBUG] DigitHeaderView displaying: \(name)")
        return HStack(alignment: .center, spacing: 16) {
            // App Logo in rounded square with border (smaller for balance)
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.digitBrand, lineWidth: DigitLayout.borderWidth)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.digitBackground))
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .frame(width: 36, height: 36) // slightly smaller for balance

            // Greeting VStack
            VStack(alignment: .leading, spacing: 0) {
                Text("Hello,")
                    .font(.digitBody)
                    .foregroundStyle(Color.digitBrand)
                Text(name)
                    .font(.system(size: 18, weight: .semibold)) // slightly smaller for balance
                    .foregroundStyle(Color.digitBrand)
            }
            .accessibilityElement(children: .combine)

            Spacer()

            // Action buttons in rounded squares with border
            HStack(spacing: 8) {
                // Calendar button
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.digitBrand, lineWidth: DigitLayout.borderWidth)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.digitBackground))
                    Image(systemName: "calendar")
                        .font(.digitIconMedium)
                        .foregroundStyle(Color.digitBrand)
                }
                .frame(width: 36, height: 36)
                .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .onTapGesture {
                    onCalendarTap?()
                }
                // Plus button (if needed in future)
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.digitBrand, lineWidth: DigitLayout.borderWidth)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.digitBrand))
                    Image(systemName: "plus")
                        .font(.digitIconMedium)
                        .foregroundStyle(Color.white)
                }
                .frame(width: 36, height: 36)
                .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(.top, topPadding)
        .padding(.horizontal, DigitLayout.Padding.horizontal)
        .padding(.bottom, bottomPadding)
        .background(Color.digitBackground.ignoresSafeArea(edges: .top))
    }
}

#if DEBUG
#Preview {
    DigitHeaderView()
}
#endif 
