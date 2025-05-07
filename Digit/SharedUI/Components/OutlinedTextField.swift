import SwiftUI

struct OutlinedTextField: View {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool = false
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.brandBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            }
            if isSecure {
                SecureField("", text: $text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            } else {
                TextField("", text: $text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.brandBlue, lineWidth: 2)
        )
        .font(.system(size: 18, weight: .regular, design: .default))
        .accessibilityLabel(placeholder)
    }
}

#if DEBUG
struct OutlinedTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            OutlinedTextField(text: .constant(""), placeholder: "Name")
            OutlinedTextField(text: .constant("Sample text"), placeholder: "Description")
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
#endif 