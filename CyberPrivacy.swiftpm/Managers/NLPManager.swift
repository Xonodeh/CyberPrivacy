import Foundation
import NaturalLanguage

class NLPManager {

    func extractEntities(from text: String, expectedType: String) -> [String: String] {
        var detected: [String: String] = [:]

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
                // Si toujours rien, prendre le premier mot (meilleur que tout le texte)
                if detected["PERSON"] == nil {
                    let firstWord = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        .split(separator: " ")
                        .first
                        .map(String.init) ?? text.trimmingCharacters(in: .whitespacesAndNewlines)
                    detected["PERSON"] = firstWord
                }
            }

        case "age":
            // Extraire les groupes de chiffres individuels
            let numberGroups = text.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .filter { !$0.isEmpty }

            // Chercher le premier nombre dans une plage d'âge plausible (1-120)
            var foundAge: String? = nil
            for group in numberGroups {
                if let num = Int(group), num >= 1, num <= 120 {
                    foundAge = String(num)
                    break
                }
            }

            // Si aucun âge direct, essayer d'interpréter comme année de naissance
            if foundAge == nil {
                let currentYear = Calendar.current.component(.year, from: Date())
                for group in numberGroups {
                    if let year = Int(group), year >= 1930, year <= currentYear - 1 {
                        foundAge = String(currentYear - year)
                        break
                    }
                }
            }

            if let age = foundAge {
                detected["AGE"] = age
            } else {
                // Patterns textuels (nombres écrits)
                let writtenNumbers: [(String, Int)] = [
                    ("twenty-one", 21), ("twenty-two", 22), ("twenty-three", 23),
                    ("twenty-four", 24), ("twenty-five", 25), ("twenty-six", 26),
                    ("twenty-seven", 27), ("twenty-eight", 28), ("twenty-nine", 29),
                    ("thirty-one", 31), ("thirty-two", 32), ("thirty-three", 33),
                    ("thirty-four", 34), ("thirty-five", 35), ("thirty-six", 36),
                    ("thirty-seven", 37), ("thirty-eight", 38), ("thirty-nine", 39),
                    ("forty-one", 41), ("forty-two", 42), ("forty-three", 43),
                    ("forty-four", 44), ("forty-five", 45), ("forty-six", 46),
                    ("forty-seven", 47), ("forty-eight", 48), ("forty-nine", 49),
                    ("fifty-one", 51), ("fifty-two", 52), ("fifty-three", 53),
                    ("fifty-four", 54), ("fifty-five", 55), ("fifty-six", 56),
                    ("fifty-seven", 57), ("fifty-eight", 58), ("fifty-nine", 59),
                    ("sixty-one", 61), ("sixty-two", 62), ("sixty-three", 63),
                    ("sixty-four", 64), ("sixty-five", 65), ("sixty-six", 66),
                    ("sixty-seven", 67), ("sixty-eight", 68), ("sixty-nine", 69),
                    ("seventy-one", 71), ("seventy-two", 72), ("seventy-three", 73),
                    ("seventy-four", 74), ("seventy-five", 75), ("seventy-six", 76),
                    ("seventy-seven", 77), ("seventy-eight", 78), ("seventy-nine", 79),
                    ("eighty-one", 81), ("eighty-two", 82), ("eighty-three", 83),
                    ("eighty-four", 84), ("eighty-five", 85), ("eighty-six", 86),
                    ("eighty-seven", 87), ("eighty-eight", 88), ("eighty-nine", 89),
                    ("ninety-one", 91), ("ninety-two", 92), ("ninety-three", 93),
                    ("ninety-four", 94), ("ninety-five", 95), ("ninety-six", 96),
                    ("ninety-seven", 97), ("ninety-eight", 98), ("ninety-nine", 99),
                    ("twenty", 20), ("thirty", 30), ("forty", 40),
                    ("fifty", 50), ("sixty", 60), ("seventy", 70),
                    ("eighty", 80), ("ninety", 90),
                    ("eighteen", 18), ("nineteen", 19),
                    ("thirteen", 13), ("fourteen", 14), ("fifteen", 15),
                    ("sixteen", 16), ("seventeen", 17)
                ]

                let lowercased = text.lowercased()
                for (pattern, value) in writtenNumbers {
                    if lowercased.contains(pattern) {
                        detected["AGE"] = String(value)
                        break
                    }
                }
            }

        case "job":
            // Mots-clés métier avec correspondance par limite de mot (word boundary)
            let jobKeywords: [(String, String)] = [
                ("student", "student"), ("studying", "student"),
                ("developer", "developer"), ("programmer", "programmer"),
                ("engineer", "engineer"), ("designer", "designer"),
                ("teacher", "teacher"), ("doctor", "doctor"),
                ("nurse", "nurse"), ("artist", "artist"),
                ("musician", "musician"), ("writer", "writer"),
                ("entrepreneur", "entrepreneur"), ("manager", "manager"),
                ("analyst", "analyst"), ("consultant", "consultant"),
                ("researcher", "researcher"), ("lawyer", "lawyer"),
                ("accountant", "accountant"), ("freelance", "freelancer"),
                ("intern", "intern"),
                ("unemployed", "unemployed"), ("retired", "retired"),
                ("study", "student"), ("school", "student"),
                ("university", "student"), ("college", "student")
            ]

            let lowercased = text.lowercased()
            for (keyword, job) in jobKeywords {
                let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
                if lowercased.range(of: pattern, options: .regularExpression) != nil {
                    detected["JOB"] = job
                    break
                }
            }

            // Si rien trouvé, prendre le texte brut
            if detected["JOB"] == nil {
                detected["JOB"] = text
            }

        case "contact":
            // Détection email (uniquement pour la question contact)
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            if let emailMatch = text.range(of: emailRegex, options: .regularExpression) {
                detected["EMAIL"] = String(text[emailMatch])
            }

            // Détection téléphone (uniquement pour la question contact)
            let phoneRegex = "(\\+?\\d{1,4}[\\s-]?)?(\\(?\\d{1,3}\\)?[\\s-]?)?[\\d\\s-]{7,15}"
            if let phoneMatch = text.range(of: phoneRegex, options: .regularExpression) {
                let phoneStr = String(text[phoneMatch])
                if phoneStr.filter({ $0.isNumber }).count >= 8 {
                    detected["PHONE"] = phoneStr
                }
            }

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
