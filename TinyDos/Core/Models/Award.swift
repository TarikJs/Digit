import SwiftUI

public struct Award: Identifiable {
    public let id: UUID = UUID()
    public let icon: String
    public let title: String
    public let color: Color
    public let bgColor: Color
    
    public init(icon: String, title: String, color: Color, bgColor: Color) {
        self.icon = icon
        self.title = title
        self.color = color
        self.bgColor = bgColor
    }
} 