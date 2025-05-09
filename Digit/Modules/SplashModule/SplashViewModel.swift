import Foundation
import SwiftUI

final class SplashViewModel: ObservableObject {
    // MARK: - Timer Logic
    func startSplashTimer(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            completion()
        }
    }
} 