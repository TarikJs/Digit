import SwiftUI

/// App-specific View extensions providing common functionality across the app
extension View {
    /// Adds a placeholder view that is shown when a condition is met
    /// - Parameters:
    ///   - shouldShow: Condition determining if the placeholder should be visible
    ///   - alignment: Alignment of the placeholder within the ZStack
    ///   - placeholder: ViewBuilder closure returning the placeholder view
    /// - Returns: A view with the placeholder overlaid when the condition is met
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    /// Applies the background color from the app's color assets
    /// - Returns: A view with the app's background color applied
    func appBackground() -> some View {
        self.background(Color.digitBackground)
    }
    
    /// Applies common styling for primary buttons in the app
    /// - Returns: A styled button view
    func primaryButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .padding()
            .background(Color.brand)
            .cornerRadius(10)
    }
    
    /// Applies common styling for secondary buttons in the app
    /// - Returns: A styled button view
    func secondaryButtonStyle() -> some View {
        self
            .foregroundColor(Color.brand)
            .padding()
            .background(Color.brand.opacity(0.1))
            .cornerRadius(10)
    }
    
    /// Conditionally applies modifiers if a condition is met
    /// - Parameters:
    ///   - condition: The condition to check
    ///   - transform: The transform to apply if the condition is true
    /// - Returns: A conditionally modified view
    @ViewBuilder func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
} 