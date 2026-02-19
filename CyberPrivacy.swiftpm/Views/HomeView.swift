import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @AppStorage("userName") private var savedName = "friend"
    @Binding var showSettings: Bool
    @State private var appeared = false

    private var displayName: String {
        viewModel.extractedData["PERSON"] ?? savedName
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // Logo
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.orange)
                    .symbolRenderingMode(.hierarchical)
                    .scaleEffect(appeared ? 1.0 : (reduceMotion ? 1.0 : 0.6))
                    .accessibilityHidden(true)

                // Title
                Text("CyberPrivacy")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundColor(.primary)

                // Welcome, {name}
                HStack(spacing: 0) {
                    Text("Welcome, ")
                        .font(.system(.title3, design: .rounded).weight(.medium))
                        .foregroundColor(.secondary)

                    Text(displayName)
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .overlay(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .mask(
                                Text(displayName)
                                    .font(.system(.title3, design: .rounded).weight(.semibold))
                            )
                        )
                        .foregroundColor(.clear)
                }

                // Description
                Text("An interactive experience that shows how easily personal data can be collected — and how to protect yourself.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 32)

                Spacer()
            }
            .frame(maxWidth: 500)
            .opacity(appeared ? 1.0 : (reduceMotion ? 1.0 : 0.0))
            .offset(y: appeared ? 0 : (reduceMotion ? 0 : 10))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Settings")
            }
        }
        .onAppear {
            withAnimation(reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }
}
