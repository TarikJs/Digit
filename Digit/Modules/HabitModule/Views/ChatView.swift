import SwiftUI

struct ChatView: View {
    var body: some View {
        Text("Chat Tab")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.digitBackground.ignoresSafeArea())
    }
}

#if DEBUG
#Preview {
    ChatView()
}
#endif 