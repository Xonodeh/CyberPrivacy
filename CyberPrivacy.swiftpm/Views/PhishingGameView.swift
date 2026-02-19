import SwiftUI

struct PhishingGameView: View {
    @StateObject private var viewModel = PhishingGameViewModel()
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            if viewModel.gameOver {
                GameOverView(viewModel: viewModel, reduceMotion: reduceMotion)
                    .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
            } else if let scenario = viewModel.currentScenario {
                GameRoundView(
                    scenario: scenario,
                    viewModel: viewModel,
                    reduceMotion: reduceMotion
                )
                .id(viewModel.currentIndex)
                .transition(reduceMotion ? .opacity : .asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startGame()
        }
    }
}

// MARK: - Game Round

private struct GameRoundView: View {
    let scenario: PhishingScenario
    @ObservedObject var viewModel: PhishingGameViewModel
    let reduceMotion: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Spot the Phish")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundStyle(.primary)

                    HStack(spacing: 16) {
                        Text("Round \(viewModel.currentIndex + 1) of \(viewModel.totalRounds)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Score: \(viewModel.score)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.blue)
                    }
                }
                .padding(.top)

                // Message Card
                ScenarioCard(scenario: scenario)

                // Action Buttons or Result
                if viewModel.showResult {
                    ResultView(
                        scenario: scenario,
                        isCorrect: viewModel.lastAnswerCorrect,
                        reduceMotion: reduceMotion
                    ) {
                        viewModel.nextRound()
                    }
                    .transition(reduceMotion ? .opacity : .scale(scale: 0.9).combined(with: .opacity))
                } else {
                    AnswerButtons { isPhishing in
                        viewModel.answer(isPhishing: isPhishing)
                    }
                    .transition(reduceMotion ? .opacity : .opacity)
                }
            }
            .padding()
            .frame(maxWidth: 600)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Scenario Card

private struct ScenarioCard: View {
    let scenario: PhishingScenario

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Sender
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text("From")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(scenario.sender)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                }
            }

            Divider()

            // Subject
            Text(scenario.subject)
                .font(.headline)
                .foregroundStyle(.primary)

            // Body
            Text(scenario.body)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Message from \(scenario.sender). Subject: \(scenario.subject). \(scenario.body)")
    }
}

// MARK: - Answer Buttons

private struct AnswerButtons: View {
    let onAnswer: (Bool) -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button {
                onAnswer(true)
            } label: {
                Label("Phishing", systemImage: "xmark.shield.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .accessibilityLabel("This is phishing")

            Button {
                onAnswer(false)
            } label: {
                Label("Legit", systemImage: "checkmark.shield.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .accessibilityLabel("This is legitimate")
        }
    }
}

// MARK: - Result View

private struct ResultView: View {
    let scenario: PhishingScenario
    let isCorrect: Bool
    let reduceMotion: Bool
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Correct/Incorrect banner
            HStack(spacing: 10) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                Text(isCorrect ? "Correct!" : "Incorrect")
                    .font(.title3.weight(.bold))
            }
            .foregroundStyle(isCorrect ? .green : .red)

            // Explanation
            Text(scenario.explanation)
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            // Red flags (for phishing scenarios)
            if scenario.isPhishing && !scenario.redFlags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Red Flags")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.red)
                        .tracking(0.5)

                    ForEach(scenario.redFlags, id: \.self) { flag in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.red.opacity(0.8))
                                .accessibilityHidden(true)

                            Text(flag)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.red.opacity(0.08))
                )
                .accessibilityElement(children: .combine)
            }

            // Next button
            Button {
                onNext()
            } label: {
                Text("Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - Game Over

private struct GameOverView: View {
    @ObservedObject var viewModel: PhishingGameViewModel
    let reduceMotion: Bool
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Score icon
            Image(systemName: scoreIcon)
                .font(.system(size: 72))
                .foregroundStyle(scoreColor)
                .symbolRenderingMode(.hierarchical)
                .scaleEffect(appeared ? 1.0 : (reduceMotion ? 1.0 : 0.5))
                .accessibilityHidden(true)

            // Score
            VStack(spacing: 8) {
                Text("\(viewModel.score) out of \(viewModel.totalRounds)")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(.primary)

                Text(viewModel.scoreMessage)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Play Again
            Button {
                viewModel.restart()
            } label: {
                Label("Play Again", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 32)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)

            Spacer()
        }
        .padding()
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.6)) {
                appeared = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Game over. You scored \(viewModel.score) out of \(viewModel.totalRounds). \(viewModel.scoreMessage)")
    }

    private var scoreIcon: String {
        switch viewModel.score {
        case 4: return "star.circle.fill"
        case 3: return "hand.thumbsup.circle.fill"
        case 2: return "exclamationmark.circle.fill"
        default: return "shield.lefthalf.filled"
        }
    }

    private var scoreColor: Color {
        switch viewModel.score {
        case 4: return .yellow
        case 3: return .green
        case 2: return .orange
        default: return .red
        }
    }
}
