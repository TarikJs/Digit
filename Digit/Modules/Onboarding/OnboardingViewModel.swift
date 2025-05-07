//
//  OnboardingViewModel.swift
//  Digit
//
//  ViewModel for onboarding flow.
//

import Foundation
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    // Closure to call when onboarding is complete
    private let onComplete: () -> Void
    
    @Published var currentPage: Int = 0
    let totalPages: Int = 2 // Adjust if more pages are added
    
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    func nextPage() {
        if currentPage < totalPages - 1 {
            currentPage += 1
        } else {
            completeOnboarding()
        }
    }
    
    func completeOnboarding() {
        onComplete()
    }
} 