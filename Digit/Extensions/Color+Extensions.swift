import SwiftUI

/// App-specific color extensions providing additional functionality
extension Color {
    /// Returns a color with adjusted opacity while preserving its other characteristics
    /// - Parameter opacity: The opacity value between 0 and 1
    /// - Returns: A new color with the specified opacity
    func withOpacity(_ opacity: Double) -> Color {
        self.opacity(opacity)
    }
    
    /// Creates a gradient from this color to another
    /// - Parameter to: The end color of the gradient
    /// - Returns: A linear gradient from this color to the specified color
    func gradient(to: Color) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [self, to]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
} 