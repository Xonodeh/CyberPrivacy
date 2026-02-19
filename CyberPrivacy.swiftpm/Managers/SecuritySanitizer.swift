import Foundation

struct SecuritySanitizer {
    
    // Vérifie si l'entrée est exploitable (pas de spam, pas trop long)
    static func isInputValid(_ input: String) -> Bool {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty { return false }

        // Trop court : un seul caractère n'est jamais une réponse valide
        if trimmed.count < 2 { return false }

        // Anti-flood : on limite la taille de la réponse
        if trimmed.count > 200 { return false }

        // Anti-spam : vérifie si l'utilisateur n'a pas tapé "aaaaa" ou "@@@@"
        let uniqueChars = Set(trimmed)
        if uniqueChars.count == 1 && trimmed.count > 2 { return false }
        
        return true
    }
    
    // Nettoie l'entrée pour éviter les injections (simulation)
    static func sanitize(_ input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // On retire les chevrons pour simuler une protection XSS basique
        let safe = trimmed.replacingOccurrences(of: "<", with: "")
                          .replacingOccurrences(of: ">", with: "")
        
        return safe
    }
}
