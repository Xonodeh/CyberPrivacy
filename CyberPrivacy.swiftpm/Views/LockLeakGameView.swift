import SwiftUI

struct LockLeakGameView: View {
    @StateObject private var viewModel = LockLeakViewModel()
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            if viewModel.gameOver {
                LockLeakGameOverView(viewModel: viewModel, reduceMotion: reduceMotion)
                    .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
            } else if let item = viewModel.currentItem {
                LockLeakRoundView(
                    item: item,
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

// MARK: - Round View

private struct LockLeakRoundView: View {
    let item: DataSensitivityItem
    @ObservedObject var viewModel: LockLeakViewModel
    let reduceMotion: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Lock or Leak")
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

                // Data Card
                DataItemCard(item: item)

                // Buttons or Result
                if viewModel.showResult {
                    LockLeakResultView(
                        item: item,
                        isCorrect: viewModel.lastAnswerCorrect,
                        reduceMotion: reduceMotion
                    ) {
                        viewModel.nextRound()
                    }
                    .transition(reduceMotion ? .opacity : .scale(scale: 0.9).combined(with: .opacity))
                } else {
                    LockLeakButtons { isSensitive in
                        viewModel.answer(isSensitive: isSensitive)
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

// MARK: - Data Item Card

private struct DataItemCard: View {
    let item: DataSensitivityItem

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(item.dataLabel)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                Text(item.context)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.dataLabel). Context: \(item.context)")
    }
}

// MARK: - Buttons

private struct LockLeakButtons: View {
    let onAnswer: (Bool) -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button {
                onAnswer(true)
            } label: {
                Label("Lock", systemImage: "lock.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .accessibilityLabel("This is sensitive, lock it")

            Button {
                onAnswer(false)
            } label: {
                Label("Leak", systemImage: "hand.thumbsup.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .accessibilityLabel("This is harmless, it's fine to share")
        }
    }
}

// MARK: - Result View

private struct LockLeakResultView: View {
    let item: DataSensitivityItem
    let isCorrect: Bool
    let reduceMotion: Bool
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                Text(isCorrect ? "Correct!" : "Incorrect")
                    .font(.title3.weight(.bold))
            }
            .foregroundStyle(isCorrect ? .green : .red)

            Text(item.explanation)
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            // Verdict tag
            HStack(spacing: 6) {
                Image(systemName: item.isSensitive ? "lock.fill" : "hand.thumbsup.fill")
                    .font(.caption.weight(.bold))
                Text(item.isSensitive ? "Sensitive — protect it" : "Harmless — safe to share")
                    .font(.caption.weight(.bold))
            }
            .foregroundStyle(item.isSensitive ? .red : .green)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(item.isSensitive ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
            )

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

private struct LockLeakGameOverView: View {
    @ObservedObject var viewModel: LockLeakViewModel
    let reduceMotion: Bool
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: scoreIcon)
                .font(.system(size: 72))
                .foregroundStyle(scoreColor)
                .symbolRenderingMode(.hierarchical)
                .scaleEffect(appeared ? 1.0 : (reduceMotion ? 1.0 : 0.5))
                .accessibilityHidden(true)

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
        let ratio = Double(viewModel.score) / Double(viewModel.totalRounds)
        switch ratio {
        case 1.0: return "star.circle.fill"
        case 0.8...: return "hand.thumbsup.circle.fill"
        case 0.5...: return "exclamationmark.circle.fill"
        default: return "shield.lefthalf.filled"
        }
    }

    private var scoreColor: Color {
        let ratio = Double(viewModel.score) / Double(viewModel.totalRounds)
        switch ratio {
        case 1.0: return .yellow
        case 0.8...: return .green
        case 0.5...: return .orange
        default: return .red
        }
    }
}
