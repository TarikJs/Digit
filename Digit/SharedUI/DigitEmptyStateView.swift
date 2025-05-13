import SwiftUI

public struct DigitEmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    public init(icon: String = "target", title: String, message: String) {
        self.icon = icon
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(.digitBrand)
                .padding(.bottom, 4)
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.digitBrand)
            Text(message)
                .font(.body)
                .foregroundColor(.digitSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
#Preview {
    DigitEmptyStateView(
        icon: "target",
        title: "No Goals Yet",
        message: "Add a goal to start tracking your daily progress."
    )
}
#endif 