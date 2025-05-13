import SwiftUI

// GitHub-style green scale (light to dark) for habit completion
public enum HabitGridColorScale {
    public static func color(for percent: Double) -> Color {
        switch percent {
        case 0.0..<0.01: return Color(hex: "E9F6E2") // very light green
        case 0.01..<0.25: return Color(hex: "B6E3A1")
        case 0.25..<0.5: return Color(hex: "6CC644")
        case 0.5..<0.75: return Color(hex: "44A340")
        case 0.75...1.0: return Color(hex: "216E39") // dark green
        default: return Color(hex: "E9F6E2")
        }
    }
} 