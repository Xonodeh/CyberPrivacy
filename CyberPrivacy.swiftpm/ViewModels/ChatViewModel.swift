import SwiftUI
import UIKit // Nécessaire pour les retours haptiques (UIImpactFeedbackGenerator)

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var extractedData: [String: String] = [:]
    @Published var isConversationFinished: Bool = false
    
    private let nlpManager = NLPManager()
    
    // Scénario d'Ingénierie Sociale (Nom -> Âge -> Job -> Contact/Phishing)
    private let questions = [
        "Hi! Welcome to CyberPrivacy. First of all, let's get to know each other. What's your name?",
        "Interesting. And if I may ask, how old are you?",
        "Got it. What do you do for a living? (Your job or studies)",
        "Perfect. To send you your personalized security report later, what is your email address or phone number?"
    ]
    
    private var currentQuestionIndex = 0
    
    func startConversation() {
        guard messages.isEmpty else { return }
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // Pause 1s au démarrage
            appendBotMessage(questions[0])
        }
    }
    
    func sendMessage() {
        guard !currentInput.isEmpty else { return }
        
        let rawInput = currentInput
        currentInput = "" // Reset immédiat de l'UI
        
        // 1. Validation de sécurité via SecuritySanitizer
        if !SecuritySanitizer.isInputValid(rawInput) {
            appendBotMessage("I'm sorry, I didn't understand. Could you please provide a clearer answer ?")
            // On joue une vibration d'erreur légère
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            return
        }
        
        // 2. Ajouter le message utilisateur
        let userMsg = ChatMessage(text: rawInput, isUser: true)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            messages.append(userMsg)
        }
        
        // 3. Assainissement des données avant envoi au "serveur" (NLP)
        let sanitized = SecuritySanitizer.sanitize(rawInput)
        
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000) // Simulation latence réseau
            
            let dataType = getDataTypeNeeded()
            let found = nlpManager.extractEntities(from: sanitized, expectedType: dataType)
            
            // Si le NLP ne trouve rien alors qu'on attend une info cruciale (sauf pour la dernière question)
            if found.isEmpty && currentQuestionIndex < questions.count {
                // Petite relance si l'IA n'a pas compris
                 appendBotMessage("I see. However, my sensors didn't detect specific details. Could you tell me more about your \(getDataTypeNeeded())?")
            } else {
                
                // Si on a capturé une donnée : CHOC HAPTIQUE
                if !found.isEmpty {
                    triggerHapticFeedback()
                    extractedData.merge(found) { (_, new) in new }
                }
                
                currentQuestionIndex += 1
                
                if currentQuestionIndex < questions.count {
                    // Question suivante
                    appendBotMessage(questions[currentQuestionIndex])
                } else {
                    // FIN DE PARTIE : Le Reveal
                    finishConversation()
                }
            }
        }
    }
    
    private func finishConversation() {
        // Construction du résumé "effrayant"
        let name = extractedData["PERSON"] ?? "friend"
        let job = extractedData["JOB"] ?? "professional"
        let age = extractedData["AGE"] ?? "unknown age"
        let contact = extractedData["EMAIL"] ?? extractedData["PHONE"] ?? extractedData["CONTACT_INFO"] ?? "contact info"
        
        let finalSummary = "Wait \(name)... Why did you give all of this to a stranger? I now know you are a \(job), aged \(age), and I can reach you at \(contact).\n\nThis data is now in my memory. Let's see how exposed you actually are."
        
        appendBotMessage(finalSummary)
        
        // Grosse vibration d'ERREUR pour marquer le coup
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        // Apparition du bouton rouge
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation(.spring()) {
                isConversationFinished = true
            }
        }
    }
    
    private func appendBotMessage(_ text: String) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
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
