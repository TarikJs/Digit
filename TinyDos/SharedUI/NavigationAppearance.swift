import SwiftUI

struct OutlinedNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.white, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(navigationTitle ?? "")
                            .font(.headline)
                            .foregroundStyle(Color.digitBrand)
                    }
                }
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.digitBrand)
                .edgesIgnoringSafeArea(.horizontal)
        }
    }
    
    private var navigationTitle: String? {
        guard let navigationController = UIApplication.shared.keyWindow?.rootViewController?.findNavigationController(),
              let title = navigationController.visibleViewController?.navigationItem.title
        else { return nil }
        return title
    }
}

extension View {
    func outlinedNavigationBar() -> some View {
        modifier(OutlinedNavigationBar())
    }
}

extension UIViewController {
    fileprivate func findNavigationController() -> UINavigationController? {
        if let nav = self as? UINavigationController {
            return nav
        }
        for child in children {
            if let nav = child.findNavigationController() {
                return nav
            }
        }
        return nil
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

extension UINavigationController {
    static var navigationBarHeight: CGFloat {
        let navigationController = UINavigationController()
        navigationController.navigationBar.sizeToFit()
        return navigationController.navigationBar.frame.height
    }
} 