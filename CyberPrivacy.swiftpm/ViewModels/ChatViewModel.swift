import SwiftUI
import UIKit // Nécessaire pour les retours haptiques (UIImpactFeedbackGenerator)

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var extractedData: [String: String] = [:]
    @Published var isConversationFinished: Bool = false

    private let nlpManager = NLPManager()

    // Première question (rien à acknowledger)
    private let firstQuestion = "Hi! Welcome to CyberPrivacy. First of all, let's get to know each other. What's your name?"

    private var currentQuestionIndex = 0
    private var repromptCount = 0

    func startConversation() {
        guard messages.isEmpty else { return }

        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // Pause 1s au démarrage
            appendBotMessage(firstQuestion)
        }
    }

    func sendMessage() {
        guard !currentInput.isEmpty else { return }

        let rawInput = currentInput
        currentInput = "" // Reset immédiat de l'UI

        // 1. Validation de sécurité via SecuritySanitizer
        if !SecuritySanitizer.isInputValid(rawInput) {
            appendBotMessage("I'm sorry, I didn't understand. Could you please provide a clearer answer?")
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            return
        }

        // 2. Ajouter le message utilisateur
        let userMsg = ChatMessage(text: rawInput, isUser: true)
        withAnimation(UIAccessibility.isReduceMotionEnabled ? .none : .spring(response: 0.4, dampingFraction: 0.7)) {
            messages.append(userMsg)
        }

        // 3. Assainissement des données avant envoi au "serveur" (NLP)
        let sanitized = SecuritySanitizer.sanitize(rawInput)

        Task {
            //  DÉLAI ALÉATOIRE 0.5s - 1.5s pour simuler réflexion IA
            let randomDelay = UInt64.random(in: 500_000_000...1_500_000_000)
            try? await Task.sleep(nanoseconds: randomDelay)

            let dataType = getDataTypeNeeded()
            let found = nlpManager.extractEntities(from: sanitized, expectedType: dataType)

            // Vérifier si on a trouvé quelque chose d'utile pour la question en cours
            let extractedSomething = hasRelevantData(found, for: dataType)

            if !extractedSomething {
                // Rien trouvé : re-prompt une fois, puis avancer
                if repromptCount < 1 {
                    repromptCount += 1
                    appendBotMessage("I see. However, my sensors didn't detect specific details. Could you tell me more about your \(dataType)?")
                } else {
                    // On a déjà relancé une fois, on avance
                    repromptCount = 0
                    advanceToNextQuestion(found: found)
                }
            } else {
                // Donnée capturée : CHOC HAPTIQUE + avancer
                triggerHapticFeedback()
                extractedData.merge(found) { (_, new) in new }
                repromptCount = 0
                advanceToNextQuestion(found: found)
            }
        }
    }

    /// Vérifie si les données extraites contiennent quelque chose de pertinent
    /// pour le type de question en cours
    private func hasRelevantData(_ found: [String: String], for dataType: String) -> Bool {
        switch dataType {
        case "name": return found["PERSON"] != nil
        case "age": return found["AGE"] != nil
        case "job": return found["JOB"] != nil
        case "contact": return found["EMAIL"] != nil || found["PHONE"] != nil || found["CONTACT_INFO"] != nil
        default: return !found.isEmpty
        }
    }

    /// Avance à la question suivante avec un acknowledgment contextuel
    private func advanceToNextQuestion(found: [String: String]) {
        let acknowledgment = buildAcknowledgment(for: currentQuestionIndex, data: found)
        currentQuestionIndex += 1

        if currentQuestionIndex < 4 {
            let nextQuestion = getNextQuestion()
            if let ack = acknowledgment {
                appendBotMessage("\(ack) \(nextQuestion)")
            } else {
                appendBotMessage(nextQuestion)
            }
        } else {
            // FIN DE PARTIE : Le Reveal
            finishConversation()
        }
    }

    /// Construit un acknowledgment basé sur les données extraites
    private func buildAcknowledgment(for questionIndex: Int, data: [String: String]) -> String? {
        switch questionIndex {
        case 0: // Après la question nom
            if let name = data["PERSON"] {
                return "Nice to meet you, \(name)!"
            }
            return "Alright!"

        case 1: // Après la question âge
            if let age = data["AGE"] {
                return "\(age), got it!"
            }
            return "Got it!"

        case 2: // Après la question job
            if let job = data["JOB"] {
                return "Oh, a \(job)? That's interesting!"
            }
            return "Interesting!"

        default:
            return nil
        }
    }

    /// Retourne la prochaine question à poser
    private func getNextQuestion() -> String {
        switch currentQuestionIndex {
        case 1: return "And if I may ask, how old are you?"
        case 2: return "What do you do for a living? (Your job or studies)"
        case 3: return "To send you your personalized security report, what's your email address or phone number?"
        default: return ""
        }
    }

    private func finishConversation() {
        let name = extractedData["PERSON"] ?? "friend"

        // Construire la liste de ce qui a été capturé
        var capturedItems: [String] = []
        if let age = extractedData["AGE"] {
            capturedItems.append("you're \(age) years old")
        }
        if let job = extractedData["JOB"] {
            capturedItems.append("you're a \(job)")
        }
        if let email = extractedData["EMAIL"] {
            capturedItems.append("your email is \(email)")
        }
        if let phone = extractedData["PHONE"] {
            capturedItems.append("your phone number is \(phone)")
        }
        if let contact = extractedData["CONTACT_INFO"] {
            capturedItems.append("your contact info is \(contact)")
        }
        if let location = extractedData["LOCATION"] {
            capturedItems.append("you're from \(location)")
        }

        let dataList: String
        if capturedItems.isEmpty {
            dataList = "your name"
        } else {
            dataList = capturedItems.joined(separator: ", ")
        }

        let finalSummary = """
Wait, \(name)... You just handed your personal data to a chatbot.

I now know: \(dataList).

Let's learn how to protect yourself.
"""

        Task {
            // DÉLAI ALÉATOIRE PLUS LONG 0.8s - 1.8s pour le message final (plus dramatique)
            let randomDelay = UInt64.random(in: 800_000_000...1_800_000_000)
            try? await Task.sleep(nanoseconds: randomDelay)

            appendBotMessage(finalSummary)

            // Persist data for subsequent launches
            UserDefaults.standard.set(true, forKey: "hasCompletedChat")
            UserDefaults.standard.set(name, forKey: "userName")

            // Activation du bouton rouge après un court délai
            try? await Task.sleep(nanoseconds: 500_000_000)
            withAnimation(UIAccessibility.isReduceMotionEnabled ? .none : .spring()) {
                isConversationFinished = true
            }
        }
    }

    private func appendBotMessage(_ text: String) {
        withAnimation(UIAccessibility.isReduceMotionEnabled ? .none : .spring(response: 0.6, dampingFraction: 0.8)) {
            messages.append(ChatMessage(text: text, isUser: false))
        }
    }

    private func getDataTypeNeeded() -> String {
        switch currentQuestionIndex {
        case 0: return "name"
        case 1: return "age"
        case 2: return "job"
        case 3: return "contact" // Le piège final
        default: return "unknown"
        }
    }

    // Fonction qui déclenche une vibration physique lourde
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
}
