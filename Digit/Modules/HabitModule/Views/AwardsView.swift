import SwiftUI

struct AwardCard: View {
    let icon: String?
    let title: String
    let subtitle: String?
    let isCompleted: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                Spacer()
                if let icon = icon {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(Color.digitBrand)
                } else {
                    Image(systemName: "questionmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(Color.digitBrand)
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.digitBrand)
                    .multilineTextAlignment(.center)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.digitSecondaryText)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isCompleted ? Color.digitHabitGreen : Color.digitBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.digitBrand, lineWidth: 2)
            )
            if isCompleted {
                ZStack {
                    Circle()
                        .fill(Color.digitBackground)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(Color.digitBrand, lineWidth: 2)
                        )
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.digitBrand)
                }
                .offset(x: -8, y: 8)
            }
        }
        .aspectRatio(1, contentMode: .fit) // Makes the card a square
    }
}

struct AwardsView: View {
    @StateObject private var viewModel = AwardsViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        ZStack {
            Color.digitGrayLight
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Awards & Challenges")
                        .font(.digitTitle2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.digitBrand)
                        .padding(.horizontal, DigitLayout.Padding.horizontal)
                        .padding(.top, 24)

                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.awards) { award in
                            AwardCard(
                                icon: award.icon,
                                title: award.title,
                                subtitle: nil,
                                isCompleted: true
                            )
                        }
                        ForEach(viewModel.challenges) { challenge in
                            AwardCard(
                                icon: challenge.icon,
                                title: challenge.title,
                                subtitle: challenge.subtitle,
                                isCompleted: challenge.isCompleted
                            )
                        }
                    }
                    .padding(.horizontal, DigitLayout.Padding.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    AwardsView()
}
#endif 
