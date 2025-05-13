import SwiftUI

// MARK: - Layout Constants
enum DigitLayout {
    /// Standard corner radius for cards and buttons (16pt)
    static let cornerRadius: CGFloat = 16
    
    /// Standard border width (1.7pt)
    static let borderWidth: CGFloat = 1.7
    
    /// Standard spacing between elements
    enum Spacing {
        /// Extra small spacing (4pt)
        static let xs: CGFloat = 4
        /// Small spacing (8pt)
        static let small: CGFloat = 8
        /// Medium spacing (12pt)
        static let medium: CGFloat = 12
        /// Large spacing (16pt)
        static let large: CGFloat = 16
        /// Extra large spacing (24pt)
        static let xl: CGFloat = 24
        /// Double extra large spacing (32pt)
        static let xxl: CGFloat = 32
    }
    
    /// Standard padding for content
    enum Padding {
        /// Standard horizontal padding (16pt)
        static let horizontal: CGFloat = 16
        /// Standard vertical padding (16pt)
        static let vertical: CGFloat = 16
        /// Content padding for cards (16pt)
        static let content: CGFloat = 16
    }
    
    /// Standard sizes for UI elements
    enum Size {
        /// Standard button height (56pt)
        static let buttonHeight: CGFloat = 56
        /// Standard icon button size (40pt)
        static let iconButton: CGFloat = 40
        /// Small icon button size (32pt)
        static let iconButtonSmall: CGFloat = 32
        /// Standard card height (120pt)
        static let cardHeight: CGFloat = 120
    }
}

// MARK: - View Extensions
extension View {
    /// Applies standard card styling
    func digitCard(color: Color = .white) -> some View {
        self
            .padding(DigitLayout.Padding.content)
            .background(color)
            .cornerRadius(DigitLayout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: DigitLayout.cornerRadius)
                    .stroke(Color.digitBrand, lineWidth: DigitLayout.borderWidth)
            )
    }
    
    /// Applies standard button styling
    func digitButton(background: Color = .digitBrand) -> some View {
        self
            .frame(height: DigitLayout.Size.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(background)
            .foregroundStyle(.white)
            .cornerRadius(DigitLayout.cornerRadius)
    }
    
    /// Applies standard icon button styling
    func digitIconButton(size: CGFloat = DigitLayout.Size.iconButton) -> some View {
        self
            .font(.digitIconSmall)
            .foregroundStyle(Color.digitBrand)
            .frame(width: size, height: size)
            .background(Color.digitBackground)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.digitBrand, lineWidth: DigitLayout.borderWidth)
            )
    }
} 