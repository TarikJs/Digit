import SwiftUI

// GitHub-style green scale (light to dark) for habit completion
public enum HabitGridColorScale {
    public static func color(for percent: Double) -> Color {
        switch percent {
        case 0.0..<0.01: return Color.clear // no color for 0%
        case 0.01..<0.25: return Color(hex: "D6F5D6") // very light green
        case 0.25..<0.5: return Color(hex: "A8E6A1") // light green
        case 0.5..<0.75: return Color(hex: "6CC644") // medium green
        case 0.75...1.0: return Color(hex: "44A340") // lighter green for 100%
        default: return Color.clear
        }
    }
} 