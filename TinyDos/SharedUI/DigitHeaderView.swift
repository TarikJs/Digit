import SwiftUI

public struct DigitHeaderView: View {
    let date: Date
    let onPlusTap: (() -> Void)?
    
    public init(date: Date, onPlusTap: (() -> Void)? = nil) {
        self.date = date
        self.onPlusTap = onPlusTap
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.black)
                        .accessibilityAddTraits(.isHeader)
                    Text(formattedDate(date))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color.digitSecondaryText)
                }
                Spacer()
                Button(action: { onPlusTap?() }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.digitBrand)
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                    .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Add Habit")
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color.digitBackground.ignoresSafeArea(edges: .top))
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

#if DEBUG
#Preview {
    DigitHeaderView(date: Date())
}
#endif 
