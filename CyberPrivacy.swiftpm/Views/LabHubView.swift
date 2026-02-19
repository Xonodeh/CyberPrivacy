import SwiftUI

struct LabHubView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "flask.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.blue)
                            .symbolRenderingMode(.hierarchical)
                            .accessibilityHidden(true)

                        Text("Security Lab")
                            .font(.system(.largeTitle, design: .rounded).weight(.bold))
                            .foregroundStyle(.primary)

                        Text("Hands-on exercises to sharpen your cyber awareness.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)

                    // Lab Cards
                    VStack(spacing: 16) {
                        NavigationLink(destination: PasswordLabView()) {
                            LabCard(
                                icon: "lock.shield.fill",
                                color: .blue,
                                title: "Password Lab",
                                description: "Test how strong your passwords are against brute-force attacks."
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .opacity(appeared ? 1.0 : (reduceMotion ? 1.0 : 0.0))
                        .offset(y: appeared ? 0 : (reduceMotion ? 0 : 20))

                        NavigationLink(destination: PhishingGameView()) {
                            LabCard(
                                icon: "fish.fill",
                                color: .red,
                                title: "Spot the Phish",
                                description: "Can you tell a scam from a real message? 4 rounds to find out."
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .opacity(appeared ? 1.0 : (reduceMotion ? 1.0 : 0.0))
                        .offset(y: appeared ? 0 : (reduceMotion ? 0 : 20))

                        NavigationLink(destination: LockLeakGameView()) {
                            LabCard(
                                icon: "lock.open.display",
                                color: .purple,
                                title: "Lock or Leak",
                                description: "Is this data sensitive or harmless? Quick-fire 6 rounds."
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .opacity(appeared ? 1.0 : (reduceMotion ? 1.0 : 0.0))
                        .offset(y: appeared ? 0 : (reduceMotion ? 0 : 20))
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
                .frame(maxWidth: 600)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}

// MARK: - Lab Card

private struct LabCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(color)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
        )
        .accessibilityElement(children: .combine)
        .accessibilityHint("Double tap to open")
        .accessibilityAddTraits(.isButton)
    }
}
