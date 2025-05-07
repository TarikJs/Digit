import SwiftUI

struct OutlinedSegmentedControl: View {
    let options: [String]
    @Binding var selectedIndex: Int
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \ .self) { idx in
                Button(action: { selectedIndex = idx }) {
                    Text(options[idx])
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedIndex == idx ? Color.brandBlue : Color.clear)
                        .foregroundColor(selectedIndex == idx ? .white : .brandBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.brandBlue, lineWidth: 2)
        )
    }
}

#if DEBUG
struct OutlinedSegmentedControl_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            OutlinedSegmentedControl(options: ["Quit habit", "Build habit"], selectedIndex: .constant(1))
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
#endif 