import Foundation
import SwiftUI

protocol SplashCoordinatorDelegate: AnyObject {
    func splashDidFinish()
}

final class SplashCoordinator: ObservableObject {
    weak var delegate: SplashCoordinatorDelegate?

    @ViewBuilder
    func makeSplashView() -> some View {
        SplashView(onFinished: { [weak self] in
            self?.delegate?.splashDidFinish()
        })
    }
} 