import SwiftUI

public struct DigitHeaderView: View {
    let name: String
    var topPadding: CGFloat
    var bottomPadding: CGFloat
    let onPlusTap: (() -> Void)?
    var isEditMode: Bool = false
    var onTrashTap: (() -> Void)? = nil

    public init(name: String = "Welcome!", topPadding: CGFloat = 16, bottomPadding: CGFloat = 16, onPlusTap: (() -> Void)? = nil, isEditMode: Bool = false, onTrashTap: (() -> Void)? = nil) {
        self.name = name
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        self.onPlusTap = onPlusTap
        self.isEditMode = isEditMode
        self.onTrashTap = onTrashTap
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .background(
                        Circle().fill(Color.white)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text("Welcome back")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.digitSecondaryText)
                    Text(name)
                        .font(.digitTitle)
                        .foregroundStyle(Color.digitBrand)
                        .accessibilityAddTraits(.isHeader)
                }
                Spacer()
                // Plus button
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
                .onTapGesture {
                    onPlusTap?()
                }
            }
            .padding(.top, topPadding)
            .padding(.horizontal, DigitLayout.Padding.horizontal)
            .padding(.bottom, bottomPadding)
            .background(Color.digitBackground.ignoresSafeArea(edges: .top))
        }
    }
}

#if DEBUG
#Preview {
    DigitHeaderView()
}
#endif 
