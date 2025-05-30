import SwiftUI

// MARK: - Font Styles
extension Font {
    /// Large title font style (32pt, bold)
    static let digitLargeTitle = Font.system(size: 32, weight: .bold)
    
    /// Title font style (24pt, bold)
    static let digitTitle = Font.system(size: 24, weight: .bold)
    
    /// Title 2 font style (20pt, semibold)
    static let digitTitle2 = Font.system(size: 20, weight: .semibold)
    
    /// Headline font style (18pt, semibold)
    static let digitHeadline = Font.system(size: 18, weight: .semibold)
    
    /// Body font style (16pt, regular)
    static let digitBody = Font.system(size: 16, weight: .regular)
    
    /// Body bold font style (16pt, semibold)
    static let digitBodyBold = Font.system(size: 16, weight: .semibold)
    
    /// Subheadline font style (14pt, regular)
    static let digitSubheadline = Font.system(size: 14, weight: .regular)
    
    /// Caption font style (12pt, regular)
    static let digitCaption = Font.system(size: 12, weight: .regular)
}

// MARK: - Icon Sizes
extension Font {
    /// Large icon size (32pt)
    static let digitIconLarge = Font.system(size: 32)
    
    /// Medium icon size (24pt)
    static let digitIconMedium = Font.system(size: 24)
    
    /// Small icon size (20pt)
    static let digitIconSmall = Font.system(size: 20)
    
    /// Extra small icon size (16pt)
    static let digitIconExtraSmall = Font.system(size: 16)
}

// MARK: - Plus Jakarta Sans Font Extension
extension Font {
    /// Returns Plus Jakarta Sans with the specified size and weight.
    static func plusJakartaSans(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .ultraLight: fontName = "PlusJakartaSans-ExtraLight"
        case .thin: fontName = "PlusJakartaSans-ExtraLight"
        case .light: fontName = "PlusJakartaSans-Light"
        case .regular: fontName = "PlusJakartaSans-Regular"
        case .medium: fontName = "PlusJakartaSans-Medium"
        case .semibold: fontName = "PlusJakartaSans-SemiBold"
        case .bold: fontName = "PlusJakartaSans-Bold"
        case .heavy: fontName = "PlusJakartaSans-ExtraBold"
        case .black: fontName = "PlusJakartaSans-ExtraBold"
        default: fontName = "PlusJakartaSans-Regular"
        }
        return .custom(fontName, size: size)
    }

    // Common weights for convenience
    static func plusJakartaRegular(size: CGFloat) -> Font {
        .custom("PlusJakartaSans-Regular", size: size)
    }
    static func plusJakartaMedium(size: CGFloat) -> Font {
        .custom("PlusJakartaSans-Medium", size: size)
    }
    static func plusJakartaSemiBold(size: CGFloat) -> Font {
        .custom("PlusJakartaSans-SemiBold", size: size)
    }
    static func plusJakartaBold(size: CGFloat) -> Font {
        .custom("PlusJakartaSans-Bold", size: size)
    }
}
