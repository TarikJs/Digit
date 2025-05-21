import SwiftUI

// MARK: - App Colors
extension Color {
    /// Official app background color (#FFFBF9)
    static let digitBackground = Color(hex: "FFFFFF")
    
    /// Official brand color (#000000)
    static let digitBrand = Color(hex: "000000")
    
    /// Official accent color 1 (#D1ED36)
    static let digitAccent1 = Color(hex: "D1ED36")
    
    /// Official accent color 2 (#F3DAFF)
    static let digitAccent2 = Color(hex: "F3DAFF")
    
    /// Official accent color red (#FC351C)
    static let digitAccentRed = Color(hex: "FC351C")

    /// Color for outline elements (same as brand color)
    static let digitOutlineBlue = digitBrand
    
    /// Color for secondary text (#6B7280)
    static let digitSecondaryText = Color(hex: "6B7280")
}

// MARK: - Habit Colors
extension Color {
    /// Green color for habits (using official accent 1)
    static let digitHabitGreen = digitAccent1
    
    /// Purple color for habits (using official accent 2)
    static let digitHabitPurple = digitAccent2
    
    /// Yellow color for habits (using accent 1 with opacity)
    static let digitHabitYellow = digitAccent1
    
    /// Red color for habits (using accent 2 with opacity)
    static let digitHabitRed = digitAccent2
    
    /// Blue color for habits (using brand color with opacity)
    static let digitHabitBlue = digitBrand
}

// MARK: - UI Colors
extension Color {
    /// Gray color for light backgrounds (#F3F4F6)
    static let digitGrayLight = Color(hex: "F3F4F6")
    
    /// Primary accent color for interactive elements (#4F46E5)
    static let digitAccentPrimary = Color(hex: "4F46E5")
    
    /// Color for dividers (brand color with 10% opacity)
    static let digitDivider = digitBrand.opacity(0.1)
}

// MARK: - Habit Progress Greens (from HabitGridColorScale)
extension Color {
    /// Very light green for 0% completion (#E9F6E2)
    static let digitProgressGreen1 = Color(hex: "E9F6E2")
    /// Light green for 1-24% completion (#B6E3A1)
    static let digitProgressGreen2 = Color(hex: "B6E3A1")
    /// Medium green for 25-49% completion (#6CC644)
    static let digitProgressGreen3 = Color(hex: "6CC644")
    /// Darker green for 50-74% completion (#44A340)
    static let digitProgressGreen4 = Color(hex: "44A340")
    /// Dark green for 75-100% completion (#216E39)
    static let digitProgressGreen5 = Color(hex: "216E39")
}

// MARK: - Color Initialization
extension Color {
    /// Initialize a color from a hex string
    /// - Parameter hex: The hex color string (e.g., "FF0000" for red)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 
