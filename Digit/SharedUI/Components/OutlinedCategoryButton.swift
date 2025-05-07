import SwiftUI

struct OutlinedCategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.headline)
            .padding(.vertical, 10)
            .padding(.horizontal, 18)
            .background(isSelected ? accentColor : Color(.systemGray6))
            .foregroundColor(isSelected ? .black : .brandBlue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? accentColor : Color.brandBlue, lineWidth: 3)
            )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct OutlinedCategoryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            OutlinedCategoryButton(title: "Body health", icon: "figure.run", isSelected: true, accentColor: .accentLime, action: {})
            OutlinedCategoryButton(title: "Mind health", icon: "brain.head.profile", isSelected: false, accentColor: .accentPurple, action: {})
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
#endif 