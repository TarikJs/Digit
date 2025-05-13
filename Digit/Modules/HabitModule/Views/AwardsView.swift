import SwiftUI

struct AwardsView: View {
    @StateObject private var viewModel = AwardsViewModel()
    @State private var currentAwardPage: Int = 0
    
    // For carousel paging
    private let awardsPerPage = 3
    private var awardPages: [[Award]] {
        stride(from: 0, to: viewModel.awards.count, by: awardsPerPage).map { i in
            Array(viewModel.awards[i..<min(i+awardsPerPage, viewModel.awards.count)])
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                // MARK: - My Awards Section
                HStack(alignment: .center) {
                    Text("My awards")
                        .font(.digitTitle2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.digitBrand)
                    Spacer()
                    Button(action: {}) {
                        Text("750 points")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.digitBrand)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.digitBrand, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, DigitLayout.Padding.horizontal)
                
                // MARK: - Awards Carousel (Horizontal ScrollView)
                VStack(spacing: 12) {
                    GeometryReader { geo in
                        let cardWidth: CGFloat = 110
                        let spacing: CGFloat = 20
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: spacing) {
                                ForEach(viewModel.awards.indices, id: \ .self) { idx in
                                    let award = viewModel.awards[idx]
                                    VStack(spacing: 8) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(award.bgColor)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.digitBrand, lineWidth: 2)
                                                )
                                            Image(systemName: award.icon)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 44, height: 44)
                                                .foregroundColor(Color.digitBrand)
                                                .padding(12)
                                        }
                                        .frame(width: cardWidth, height: cardWidth)
                                        Text(award.title)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(Color.digitBrand)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(width: cardWidth)
                                }
                            }
                            .padding(.horizontal, (geo.size.width - cardWidth) / 2)
                        }
                        .content.offset(x: CGFloat(currentAwardPage) * -(cardWidth + spacing))
                        .frame(width: geo.size.width, height: cardWidth + 36)
                    }
                    .frame(height: 146)
                    // Custom page indicator
                    HStack(spacing: 12) {
                        ForEach(0..<awardPages.count, id: \ .self) { idx in
                            ZStack {
                                Circle()
                                    .stroke(Color.digitBrand, lineWidth: 2)
                                    .frame(width: 12, height: 12)
                                if idx == currentAwardPage {
                                    Circle()
                                        .fill(Color.digitBrand)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 8)
                
                // MARK: - Challenges Section
                Text("Challenges")
                    .font(.digitTitle2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.digitBrand)
                    .padding(.horizontal, DigitLayout.Padding.horizontal)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(viewModel.challenges) { challenge in
                        ZStack(alignment: .topTrailing) {
                            VStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(challenge.bgColor)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.digitBrand, lineWidth: 2)
                                        )
                                    if let icon = challenge.icon {
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
                                }
                                .frame(width: 56, height: 56)
                                Text(challenge.title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.digitBrand)
                                Text(challenge.subtitle)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.digitSecondaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(challenge.isCompleted ? Color.digitHabitGreen : Color.digitBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.digitBrand, lineWidth: 2)
                            )
                            // Checkmark badge
                            if challenge.isCompleted {
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
                                .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
                .padding(.horizontal, DigitLayout.Padding.horizontal)
                .padding(.bottom, 24)
            }
            .padding(.top, 24)
        }
        .background(Color.digitBackground)
    }
}

#if DEBUG
#Preview {
    AwardsView()
}
#endif 
