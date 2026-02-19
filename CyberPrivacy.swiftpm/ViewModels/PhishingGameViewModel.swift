import SwiftUI
import UIKit

@MainActor
class PhishingGameViewModel: ObservableObject {
    @Published var scenarios: [PhishingScenario] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var showResult: Bool = false
    @Published var lastAnswerCorrect: Bool = false
    @Published var gameOver: Bool = false

    var currentScenario: PhishingScenario? {
        guard currentIndex < scenarios.count else { return nil }
        return scenarios[currentIndex]
    }

    var totalRounds: Int { scenarios.count }

    func startGame() {
        scenarios = PhishingScenarios.randomSelection(count: 4)
        currentIndex = 0
        score = 0
        showResult = false
        lastAnswerCorrect = false
        gameOver = false
    }

    func answer(isPhishing: Bool) {
        guard let scenario = currentScenario, !showResult else { return }

        lastAnswerCorrect = (isPhishing == scenario.isPhishing)
        if lastAnswerCorrect {
            score += 1
        }

        // Retour haptique
        if lastAnswerCorrect {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }

        // Annonce VoiceOver
        let announcement = lastAnswerCorrect ? "Correct!" : "Incorrect."
        UIAccessibility.post(notification: .announcement, argument: announcement)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showResult = true
        }
    }

    func nextRound() {
        if currentIndex + 1 >= scenarios.count {
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
        switch score {
        case 4: return "Perfect! You're a phishing expert!"
        case 3: return "Great job! You spotted most of them."
        case 2: return "Not bad, but stay vigilant!"
        case 1: return "Careful — phishing can be tricky."
        default: return "Time to brush up on your phishing awareness!"
        }
    }
}
