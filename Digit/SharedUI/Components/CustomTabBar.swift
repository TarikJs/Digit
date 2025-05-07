import SwiftUI

// === Customization Variables ===
private let lineHeight: CGFloat = 1.5
private let iconSize: CGFloat = 28
private let buttonSize: CGFloat = 52
private let borderWidth: CGFloat = 1.5
private let tabCornerRadius: CGFloat = 6
private let shadowOffsetX: CGFloat = 3
private let shadowOffsetY: CGFloat = 3
private let selectedShadow1OffsetX: CGFloat = 1.2 // white shadow
private let selectedShadow1OffsetY: CGFloat = 1.2
private let selectedShadow2OffsetX: CGFloat = 3 // blue shadow
private let selectedShadow2OffsetY: CGFloat = 3
// ==============================

enum MainTab: Int, CaseIterable {
    case home, stats, achievements, settings
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .stats: return "chart.bar.fill"
        case .achievements: return "rosette"
        case .settings: return "gearshape.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.brandBlue)
                .frame(height: lineHeight)
                .frame(maxWidth: .infinity)
            HStack(spacing: 36) {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    TabBarButton(
                        icon: tab.icon,
                        isSelected: selectedTab == tab,
                        action: { selectedTab = tab }
                    )
                    .accessibilityLabel(Text("Tab: \(tab.icon)"))
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 0)
        }
        .background(Color.offWhite.ignoresSafeArea(.all, edges: .bottom))
    }
}

private struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    // Selected: filled, white shadow, blue shadow, border, icon
                    RoundedRectangle(cornerRadius: tabCornerRadius)
                        .fill(Color.brandBlue)
                        .frame(width: buttonSize, height: buttonSize)
                        .shadow(color: .white, radius: 0, x: selectedShadow1OffsetX, y: selectedShadow1OffsetY)
                        .shadow(color: Color(hex: "#23409A"), radius: 0, x: selectedShadow2OffsetX, y: selectedShadow2OffsetY)
                        .overlay(
                            RoundedRectangle(cornerRadius: tabCornerRadius)
                                .stroke(Color.brandBlue, lineWidth: borderWidth)
                        )
                } else {
                    // Non-selected: filled, blue shadow, border, icon
                    RoundedRectangle(cornerRadius: tabCornerRadius)
                        .fill(Color.offWhite)
                        .frame(width: buttonSize, height: buttonSize)
                        .shadow(color: Color(hex: "#23409A"), radius: 0, x: shadowOffsetX, y: shadowOffsetY)
                        .overlay(
                            RoundedRectangle(cornerRadius: tabCornerRadius)
                                .stroke(Color.brandBlue, lineWidth: borderWidth)
                        )
                }
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(isSelected ? .white : .brandBlue)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StatefulPreviewWrapper(value: MainTab.home) { CustomTabBar(selectedTab: $0) }
}

// Helper for previewing with @Binding
struct StatefulPreviewWrapper<Value: Equatable, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content
    var body: some View { content($value) }
} 
