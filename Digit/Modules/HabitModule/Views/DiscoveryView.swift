import SwiftUI

struct DiscoveryView: View {
    var body: some View {
        Text("Discovery Tab")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.digitBackground.ignoresSafeArea())
    }
}

#if DEBUG
#Preview {
    DiscoveryView()
}
#endif 