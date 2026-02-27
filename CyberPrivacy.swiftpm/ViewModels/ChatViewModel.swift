import SwiftUI
import UIKit

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var extractedData: [String: String] = [:]
    @Published var isConversationFinished: Bool = false

    private let nlpManager = NLPManager()
    private let firstQuestion = "Hi! Welcome to CyberPrivacy. First of all, let's get to know each other. What's your name?"
    private var currentQuestionIndex = 0
    private var repromptCount = 0

    func startConversation() {
        guard messages.isEmpty else { return }

        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            appendBotMessage(firstQuestion)
        }
    }

    func resetConversation() {
        messages = []
        currentInput = ""
        extractedData = [:]
        isConversationFinished = false
        currentQuestionIndex = 0
        repromptCount = 0
    }

    func sendMessage() {
        guard !currentInput.isEmpty else { return }

        let rawInput = currentInput
        currentInput = ""

        // Always display the user message in the chat
        let userMsg = ChatMessage(text: rawInput, isUser: true)
        withAnimation(UIAccessibility.isReduceMotionEnabled ? .none : .spring(response: 0.4, dampingFraction: 0.7)) {
            messages.append(userMsg)
        }

        // Validate input
        if !SecuritySanitizer.isInputValid(rawInput) {
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                appendBotMessage("I'm sorry, I didn't understand. Could you please provide a clearer answer?")
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            return
        }

        let sanitized = SecuritySanitizer.sanitize(rawInput)

        Task {
            // Random delay (0.5s-1.5s) to simulate AI thinking
            let randomDelay = UInt64.random(in: 500_000_000...1_500_000_000)
            try? await Task.sleep(nanoseconds: randomDelay)

            let dataType = getDataTypeNeeded()
            let found = nlpManager.extractEntities(from: sanitized, expectedType: dataType)
            let extractedSomething = hasRelevantData(found, for: dataType)

            if !extractedSomething {
                if repromptCount < 1 {
                    repromptCount += 1
                    appendBotMessage("I see. However, my sensors didn't detect specific details. Could you tell me more about your \(dataType)?")
                } else {
                    repromptCount = 0
                    advanceToNextQuestion(found: found)
                }
            } else {
                triggerHapticFeedback()
                extractedData.merge(found) { (_, new) in new }
                repromptCount = 0
                advanceToNextQuestion(found: found)
            }
        }
    }

    /// Checks if extracted data contains relevant information for the current question type
    private func hasRelevantData(_ found: [String: String], for dataType: String) -> Bool {
        switch dataType {
        case "name": return found["PERSON"] != nil
        case "age": return found["AGE"] != nil
        case "job": return found["JOB"] != nil
        case "contact": return found["EMAIL"] != nil || found["PHONE"] != nil || found["CONTACT_INFO"] != nil
        default: return !found.isEmpty
        }
    }

    /// Advances to the next question with a contextual acknowledgment
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
            finishConversation()
        }
    }

    /// Builds a contextual acknowledgment based on extracted data
    private func buildAcknowledgment(for questionIndex: Int, data: [String: String]) -> String? {
        switch questionIndex {
        case 0:
            if let name = data["PERSON"] {
                return "Nice to meet you, \(name)!"
            }
            return "Alright!"
        case 1:
            if let age = data["AGE"] {
                return "\(age), got it!"
            }
            return "Got it!"
        case 2:
            if let job = data["JOB"] {
                return "Oh, a \(job)? That's interesting!"
            }
            return "Interesting!"
        default:
            return nil
        }
    }

    /// Returns the next question to ask
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
            // Longer random delay (0.8s-1.8s) for dramatic effect
            let randomDelay = UInt64.random(in: 800_000_000...1_800_000_000)
            try? await Task.sleep(nanoseconds: randomDelay)

            appendBotMessage(finalSummary)

            UserDefaults.standard.set(true, forKey: "hasCompletedChat")
            UserDefaults.standard.set(name, forKey: "userName")

            // Show the final CTA button after a short delay
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
        case 3: return "contact"
        default: return "unknown"
        }
    }

    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
}
