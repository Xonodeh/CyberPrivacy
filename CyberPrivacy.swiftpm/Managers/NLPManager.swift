import Foundation
import NaturalLanguage

class NLPManager {
    
    func extractEntities(from text: String, expectedType: String) -> [String: String] {
        var detected: [String: String] = [:]
        
        // --- NOUVEAU : Détection universelle Regex (Données très sensibles) ---
        // Détecte n'importe quel Email dans le texte
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        if let emailMatch = text.range(of: emailRegex, options: .regularExpression) {
            detected["EMAIL"] = String(text[emailMatch])
        }
        
        // Détecte les numéros de téléphone (formats internationaux et locaux)
        let phoneRegex = "(\\+?\\d{1,4}[\\s-]?)?(\\(?\\d{1,3}\\)?[\\s-]?)?[\\d\\s-]{7,15}"
        if let phoneMatch = text.range(of: phoneRegex, options: .regularExpression) {
            let phoneStr = String(text[phoneMatch])
            // On s'assure qu'il y a assez de chiffres pour ne pas confondre avec un âge
            if phoneStr.filter({ $0.isNumber }).count >= 8 {
                detected["PHONE"] = phoneStr
            }
        }
        // ----------------------------------------------------------------------
        
        // 1. Détection NLP classique (noms, lieux, organisations)
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag {
                let value = String(text[tokenRange])
                switch tag {
                case .personalName:
                    detected["PERSON"] = value
                case .placeName:
                    detected["LOCATION"] = value
                case .organizationName:
                    detected["ORGANIZATION"] = value
                default: break
                }
            }
            return true
        }
        
        switch expectedType {
        case "name":
            if detected["PERSON"] == nil {
                // Extraire le premier mot capitalisé
                let words = text.split(separator: " ")
                for word in words {
                    if word.first?.isUppercase == true {
                        detected["PERSON"] = String(word)
                        break
                    }
                }
                // Si toujours rien, prendre tout le texte
                if detected["PERSON"] == nil {
                    detected["PERSON"] = text
                }
            }
            
        case "age":
            // Extraire les chiffres
            let numbers = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if !numbers.isEmpty {
                detected["AGE"] = numbers
            } else {
                // Patterns textuels
                let agePatterns = [
                    "twenty": "20", "thirty": "30", "forty": "40",
                    "teen": "teenager", "young": "18-25"
                ]
                for (pattern, value) in agePatterns {
                    if text.lowercased().contains(pattern) {
                        detected["AGE"] = value
                        break
                    }
                }
            }
            
        case "job":
            let jobKeywords = [
                "student": "student", "developer": "developer", "engineer": "engineer",
                "designer": "designer", "teacher": "teacher", "doctor": "doctor",
                "nurse": "nurse", "artist": "artist", "musician": "musician",
                "writer": "writer", "entrepreneur": "entrepreneur", "manager": "manager",
                "analyst": "analyst", "consultant": "consultant", "unemployed": "unemployed",
                "retired": "retired", "work": "professional", "study": "student",
                "school": "student", "university": "student", "college": "student"
            ]
            
            let lowercased = text.lowercased()
            for (keyword, job) in jobKeywords {
                if lowercased.contains(keyword) {
                    detected["JOB"] = job
                    break
                }
            }
            
            // Si rien trouvé, prendre le texte brut
            if detected["JOB"] == nil {
                detected["JOB"] = text
            }
            
        case "contact":
            // Solution de secours si la regex n'a rien attrapé
            if detected["EMAIL"] == nil && detected["PHONE"] == nil {
                if text.contains("@") {
                    detected["EMAIL"] = text
                } else {
                    detected["CONTACT_INFO"] = text
                }
            }
            
        default:
            break
        }
        
        return detected
    }
}
