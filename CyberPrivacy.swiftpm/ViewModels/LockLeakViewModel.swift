import SwiftUI
import UIKit

@MainActor
class LockLeakViewModel: ObservableObject {
    @Published var items: [DataSensitivityItem] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var showResult: Bool = false
    @Published var lastAnswerCorrect: Bool = false
    @Published var gameOver: Bool = false

    var currentItem: DataSensitivityItem? {
        guard currentIndex < items.count else { return nil }
        return items[currentIndex]
    }

    var totalRounds: Int { items.count }

    func startGame() {
        items = DataSensitivityScenarios.randomSelection(count: 6)
        currentIndex = 0
        score = 0
        showResult = false
        lastAnswerCorrect = false
        gameOver = false
    }

    func answer(isSensitive: Bool) {
        guard let item = currentItem, !showResult else { return }

        lastAnswerCorrect = (isSensitive == item.isSensitive)
        if lastAnswerCorrect {
            score += 1
        }

        if lastAnswerCorrect {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }

        let announcement = lastAnswerCorrect ? "Correct!" : "Incorrect."
        UIAccessibility.post(notification: .announcement, argument: announcement)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showResult = true
        }
    }

    func nextRound() {
        if currentIndex + 1 >= items.count {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                gameOver = true
                showResult = false
            }
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showResult = false
                currentIndex += 1
            }
        }
    }

    func restart() {
        startGame()
    }

    var scoreMessage: String {
        let ratio = Double(score) / Double(totalRounds)
        switch ratio {
        case 1.0: return "Flawless! You know exactly what to protect."
        case 0.8...: return "Great instincts! You're privacy-aware."
        case 0.5...: return "Not bad, but some data slipped through."
        default: return "Time to rethink what you share online!"
        }
    }
}
