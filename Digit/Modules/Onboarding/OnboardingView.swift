//
//  OnboardingView.swift
//  Digit
//
//  SwiftUI onboarding flow for new users.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var requestedNotifications = false
    
    var body: some View {
        VStack(spacing: Constants.onboardingSpacing) {
            Spacer()
            Group {
                if viewModel.currentPage == 0 {
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(Color.accentColor)
                            .accessibilityHidden(true)
                        Text(Constants.onboardingTitle)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                        Text(Constants.onboardingDescription)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                } else if viewModel.currentPage == 1 {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.badge")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(Color.accentColor)
                            .accessibilityHidden(true)
                        Text(NSLocalizedString("onboarding_reminders_title", comment: "Reminders onboarding title"))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        Text(NSLocalizedString("onboarding_reminders_desc", comment: "Reminders onboarding description"))
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
            Button(action: {
                viewModel.nextPage()
                if viewModel.currentPage == viewModel.totalPages - 1 && !requestedNotifications {
                    requestedNotifications = true
                    NotificationService.shared.requestAuthorization { _ in }
                }
            }) {
                Text(viewModel.currentPage == viewModel.totalPages - 1 ? NSLocalizedString("get_started_button", comment: "Get Started") : NSLocalizedString("next_button", comment: "Next"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .accessibilityLabel(viewModel.currentPage == viewModel.totalPages - 1 ? NSLocalizedString("get_started_button", comment: "Get Started") : NSLocalizedString("next_button", comment: "Next"))
            }
            .padding(.horizontal)
            .accessibilityHint(viewModel.currentPage == viewModel.totalPages - 1 ? NSLocalizedString("get_started_hint", comment: "Completes onboarding") : NSLocalizedString("next_hint", comment: "Go to next onboarding page"))
            .accessibilityAddTraits(.isButton)
        }
        .padding()
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .all)
    }
} 