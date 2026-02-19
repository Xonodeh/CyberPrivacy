import SwiftUI

struct LockTransitionView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var currentIcon = "faceid"
    @State private var scale: CGFloat = 0.9
    @State private var opacity = 0.0
    @State private var rotation: Double = 0
    @State private var blurRadius: CGFloat = 0

    var onComplete: () -> Void

    var body: some View {
        ZStack {
            // Fond avec blur progressif (liquid glass effect)
            Color.white
                .opacity(0.01)
                .background(.ultraThinMaterial)
                .blur(radius: blurRadius)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // L'icône qui morphe
                Image(systemName: currentIcon)
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(
                        currentIcon == "faceid"
                            ? Color.blue.opacity(0.9)
                            : Color.green.opacity(0.9)
                    )
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                    .opacity(opacity)
                    .accessibilityHidden(true)

                // Texte qui change
                Text(currentIcon == "faceid"
                     ? "Analyzing"
                     : "Let's learn how to secure your digital life")
                    .font(.subheadline)
                    .foregroundStyle(.primary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: 500)
                    .opacity(opacity)

                Spacer()
            }
        }
        .onAppear {
            if reduceMotion {
                animateReduced()
            } else {
                animateSequence()
            }
        }
    }

    /// Reduce Motion: show lock icon + text instantly, wait 1.5s, complete
    private func animateReduced() {
        currentIcon = "lock.fill"
        opacity = 1.0
        scale = 1.0
        blurRadius = 20

        UIAccessibility.post(notification: .announcement, argument: "Let's learn how to secure your digital life")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onComplete()
        }
    }

    private func animateSequence() {
        // Phase 1 : Fade in Face ID + blur (0.0s → 0.5s)
        withAnimation(.easeOut(duration: 0.5)) {
            opacity = 1.0
            scale = 1.0
            blurRadius = 20
        }

        // Phase 2 : Transition vers lock (1.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                scale = 0.8
                opacity = 0.0
            }

            // Switch icône
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentIcon = "lock.fill"

                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                    rotation = 15
                    blurRadius = 25 // Plus de blur pour effet liquid
                }

                // Haptic
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()

                UIAccessibility.post(notification: .announcement, argument: "Let's learn how to secure your digital life")
            }
        }

        // Phase 3 : Fade out (3.0s - plus long pour lire le message)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 0.0
                blurRadius = 40
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete()
            }
        }
    }
}
