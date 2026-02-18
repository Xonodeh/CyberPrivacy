import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var appear = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Logo + Titre côte à côte
                HStack(spacing: 15) {
                    Image(systemName: "swift")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.orange)
                        .padding(12)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text("CyberPrivacy")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                }
                .opacity(appear ? 1 : 0)
                .scaleEffect(appear ? 1 : 0.9)
                
                // Loader simple noir qui tourne
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
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appear = true
            }
        }
    }
}
