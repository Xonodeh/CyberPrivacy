import SwiftUI

struct SplashScreenView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isAnimating = false
    @State private var appear = false

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(spacing: 25) {
                // Logo + Titre côte à côte
                HStack(spacing: 15) {
                    Image(systemName: "swift")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundColor(.orange)
                        .padding(12)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Circle())

                    Text("CyberPrivacy")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                }
                .opacity(appear ? 1 : (reduceMotion ? 1 : 0))
                .scaleEffect(appear ? 1 : (reduceMotion ? 1 : 0.9))

                // Loader simple noir qui tourne
                if !reduceMotion {
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.primary, lineWidth: 3)
                        .frame(width: 30, height: 30)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .opacity(appear ? 1 : 0)
                        .onAppear {
                            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                isAnimating = true
                            }
                        }
                        .accessibilityHidden(true)
                }
            }
        }
        .onAppear {
            if reduceMotion {
                appear = true
            } else {
                withAnimation(.easeOut(duration: 0.8)) {
                    appear = true
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("CyberPrivacy. Loading.")
    }
}
