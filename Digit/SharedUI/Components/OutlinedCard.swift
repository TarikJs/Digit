import SwiftUI

struct OutlinedCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        content
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.brandBlue, lineWidth: 3)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            )
    }
}

#if DEBUG
struct OutlinedCard_Previews: PreviewProvider {
    static var previews: some View {
        OutlinedCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Goal per day")
                Toggle("", isOn: .constant(true))
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}
#endif 