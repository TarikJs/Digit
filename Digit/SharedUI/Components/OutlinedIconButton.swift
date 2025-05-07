import SwiftUI

struct OutlinedIconButton: View {
    let icon: String
    let isSelected: Bool
    let fillColor: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? fillColor : Color(.systemGray6))
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.brandBlue : Color.brandBlue.opacity(0.5), lineWidth: 3)
                    )
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.brandBlue)
            }
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct OutlinedIconButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 16) {
            OutlinedIconButton(icon: "book.fill", isSelected: true, fillColor: .accentLime, action: {})
            OutlinedIconButton(icon: "bed.double.fill", isSelected: false, fillColor: .accentLime, action: {})
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
#endif 