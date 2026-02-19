import SwiftUI

struct PasswordLabView: View {
    @StateObject private var viewModel = PasswordViewModel()
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea() // Fond clair iOS standard

            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(statusColor)
                            .shadow(radius: 2)
                            .accessibilityHidden(true)

                        Text("Password Lab")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)

                        Text("Discover how brute-force algorithms see your digital secrets.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)

                    // Input Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TEST A PASSWORD")
                            .font(.caption.bold())
                            .foregroundColor(.blue)
                            .tracking(1)

                        HStack {
                            SecureField("", text: $viewModel.passwordToTest, prompt: Text("Type here...").foregroundColor(.gray))
                                .focused($isFocused)
                                .accessibilityLabel("Password input")
                                .accessibilityHint("Type a password to test its strength")

                            if !viewModel.passwordToTest.isEmpty {
                                Button(action: { viewModel.passwordToTest = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .accessibilityLabel("Clear password")
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }

                    // Strength Indicator
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Estimated Strength:")
                                .font(.headline)
                            Spacer()
                            Text(strengthLabel)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(statusColor)
                            Text(viewModel.crackTime)
                                .bold()
                                .foregroundColor(statusColor)
                        }

                        ProgressView(value: viewModel.strengthScore)
                            .tint(statusColor)
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .accessibilityHidden(true)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Password strength: \(strengthLabel). Crack time: \(viewModel.crackTime)")

                    // Fingerprint Section (Hash)
                    VStack(alignment: .leading, spacing: 10) {
                        Label("DIGITAL FINGERPRINT (SHA-256)", systemImage: "number")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)

                        Text(viewModel.sha256Hash.isEmpty ? "Awaiting input..." : viewModel.sha256Hash)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(viewModel.sha256Hash.isEmpty ? .secondary : .blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.black.opacity(0.03))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
                            )
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(viewModel.sha256Hash.isEmpty ? "SHA-256 hash: awaiting input" : "SHA-256 hash generated")

                    // Pedagogical Note
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                        Text("In cybersecurity, passwords are never stored in plain text. Instead, we use a 'hash' to verify your input without ever knowing the original password.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.08))
                    .cornerRadius(12)
                    .accessibilityElement(children: .combine)
                }
                .padding()
                .frame(maxWidth: 600)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var strengthLabel: String {
        if viewModel.passwordToTest.isEmpty { return "" }
        if viewModel.strengthScore < 0.4 { return "Weak" }
        if viewModel.strengthScore < 0.7 { return "Medium" }
        return "Strong"
    }

    private var statusColor: Color {
        if viewModel.passwordToTest.isEmpty { return .blue }
        if viewModel.strengthScore < 0.4 { return .red }
        if viewModel.strengthScore < 0.7 { return .orange }
        return .green
    }
}
