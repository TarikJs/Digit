import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel = SplashViewModel()
    var onFinished: (() -> Void)?
    
    // Animation states
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: CGFloat = 0
    @State private var loadingOpacity: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.brand
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // App Logo
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                // Loading Indicator
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                    .opacity(loadingOpacity)
            }
        }
        .onAppear {
            // Animate logo appearance
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1
            }
            
            // Animate loading indicator after logo
            withAnimation(.easeIn.delay(0.3)) {
                loadingOpacity = 1
            }
            
            // Start splash timer
            viewModel.startSplashTimer {
                // Animate out before finishing
                withAnimation(.easeOut(duration: 0.2)) {
                    logoOpacity = 0
                    loadingOpacity = 0
                }
                
                // Small delay before calling onFinished
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onFinished?()
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Digit App is loading")
    }
}

#if DEBUG
#Preview {
    SplashView()
}
#endif 