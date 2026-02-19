import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var showWelcome = true
    @State private var welcomeAppeared = false

    var body: some View {
        ZStack {
            TabView {
                NavigationStack {
                    AuditView()
                }
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }

                NavigationStack {
                    LabHubView()
                }
                .tabItem {
                    Label("Lab", systemImage: "flask.fill")
                }

                NavigationStack {
                    TipsView()
                }
                .tabItem {
                    Label("Tips", systemImage: "lightbulb.fill")
                }
            }
            .accentColor(.blue)

            // Welcome overlay
            if showWelcome {
                WelcomeOverlay(
                    name: viewModel.extractedData["PERSON"] ?? "friend",
                    appeared: welcomeAppeared,
                    reduceMotion: reduceMotion
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .onAppear {
            withAnimation(reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.8)) {
                welcomeAppeared = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(reduceMotion ? .none : .easeOut(duration: 0.6)) {
                    showWelcome = false
                }
            }
        }
    }
}

// MARK: - Welcome Overlay

private struct WelcomeOverlay: View {
    let name: String
    let appeared: Bool
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
                    .symbolRenderingMode(.hierarchical)
                    .scaleEffect(appeared ? 1.0 : (reduceMotion ? 1.0 : 0.5))
                    .accessibilityHidden(true)

                VStack(spacing: 8) {
                    Text("Welcome to CyberPrivacy")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(.primary)

                    Text(name)
                        .font(.system(.title3, design: .rounded).weight(.medium))
                        .foregroundStyle(.blue)
                }
                .opacity(appeared ? 1.0 : (reduceMotion ? 1.0 : 0.0))
                .offset(y: appeared ? 0 : (reduceMotion ? 0 : 10))
            }
            .frame(maxWidth: 400)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Welcome to CyberPrivacy, \(name)")
    }
}
