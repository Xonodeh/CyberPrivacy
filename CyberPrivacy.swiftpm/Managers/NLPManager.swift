import Foundation
import NaturalLanguage

class NLPManager {

    // MARK: - Written Numbers (generated programmatically)

    private static let writtenNumbers: [String: Int] = {
        let ones = ["", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
        let teens = ["ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen",
                     "sixteen", "seventeen", "eighteen", "nineteen"]
        let tens = ["", "", "twenty", "thirty", "forty", "fifty",
                    "sixty", "seventy", "eighty", "ninety"]

        var map: [String: Int] = [:]

        for i in 1...9 { map[ones[i]] = i }
        for (i, word) in teens.enumerated() { map[word] = 10 + i }
        for i in 2...9 { map[tens[i]] = i * 10 }

        // Compound forms: "twenty-one", "twenty one"
        for t in 2...9 {
            for o in 1...9 {
                let value = t * 10 + o
                map["\(tens[t])-\(ones[o])"] = value
                map["\(tens[t]) \(ones[o])"] = value
            }
        }

        return map
    }()

    // MARK: - Job Keywords

    private static let jobKeywords: [(keyword: String, job: String)] = [
        // Tech
        ("developer", "developer"), ("programmer", "programmer"), ("engineer", "engineer"),
        ("designer", "designer"), ("architect", "architect"), ("coding", "developer"),
        ("software", "software engineer"),
        // Healthcare
        ("doctor", "doctor"), ("nurse", "nurse"), ("pharmacist", "pharmacist"),
        ("dentist", "dentist"), ("therapist", "therapist"), ("surgeon", "surgeon"),
        ("veterinarian", "veterinarian"),
        // Education
        ("teacher", "teacher"), ("professor", "professor"), ("tutor", "tutor"),
        ("student", "student"), ("studying", "student"), ("study", "student"),
        ("school", "student"), ("university", "student"), ("college", "student"),
        // Creative
        ("artist", "artist"), ("musician", "musician"), ("writer", "writer"),
        ("photographer", "photographer"), ("filmmaker", "filmmaker"), ("animator", "animator"),
        ("actor", "actor"), ("actress", "actress"),
        // Business
        ("entrepreneur", "entrepreneur"), ("manager", "manager"), ("analyst", "analyst"),
        ("consultant", "consultant"), ("accountant", "accountant"), ("marketing", "marketer"),
        ("salesperson", "salesperson"), ("banker", "banker"), ("trader", "trader"),
        // Science
        ("researcher", "researcher"), ("scientist", "scientist"), ("biologist", "biologist"),
        ("chemist", "chemist"), ("physicist", "physicist"),
        // Trade & Service
        ("chef", "chef"), ("cook", "cook"), ("pilot", "pilot"),
        ("mechanic", "mechanic"), ("electrician", "electrician"), ("plumber", "plumber"),
        ("carpenter", "carpenter"), ("barber", "barber"), ("firefighter", "firefighter"),
        // Legal & Media
        ("lawyer", "lawyer"), ("attorney", "attorney"), ("paralegal", "paralegal"),
        ("journalist", "journalist"), ("editor", "editor"),
        // Other
        ("freelance", "freelancer"), ("intern", "intern"),
        ("unemployed", "unemployed"), ("retired", "retired")
    ]

    // Words to ignore when falling back to raw text for job detection
    private static let stopWords: Set<String> = [
        "the", "and", "for", "are", "but", "not", "you", "all", "can", "had",
        "her", "was", "one", "our", "out", "has", "have", "been", "some", "them",
        "than", "its", "over", "that", "this", "with", "will", "each", "from",
        "they", "into", "just", "also", "very", "much", "any", "don", "doesn",
        "didn", "won", "isn", "aren", "work", "working", "doing", "right", "now",
        "yes", "yeah", "nah", "well", "like", "really", "actually", "currently",
        "basically", "know", "think", "what", "about", "could", "would", "should"
    ]

    // MARK: - Public API

    func extractEntities(from text: String, expectedType: String) -> [String: String] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var detected = runNLPTagger(on: trimmed)

        switch expectedType {
        case "name":    extractName(from: trimmed, into: &detected)
        case "age":     extractAge(from: trimmed, into: &detected)
        case "job":     extractJob(from: trimmed, into: &detected)
        case "contact": extractContact(from: trimmed, into: &detected)
        default: break
        }

        return detected
    }

    // MARK: - NLP Tagger

    private func runNLPTagger(on text: String) -> [String: String] {
        var detected: [String: String] = [:]
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text

        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag {
                let value = String(text[tokenRange])
                switch tag {
                case .personalName where value.count >= 2:
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
        return detected
    }

    // MARK: - Name

    private func extractName(from text: String, into detected: inout [String: String]) {
        guard detected["PERSON"] == nil else { return }

        let words = text.split(separator: " ").map(String.init)

        // Try capitalized words first (min 2 chars, letters/hyphens only)
        for word in words {
            if word.count >= 2
                && word.first?.isUppercase == true
                && word.allSatisfy({ $0.isLetter || $0 == "-" }) {
                detected["PERSON"] = word
                return
            }
        }

        // Last resort: accept the first valid word, auto-capitalized
        if let first = words.first,
           first.count >= 2,
           first.allSatisfy({ $0.isLetter || $0 == "-" }) {
            detected["PERSON"] = first.prefix(1).uppercased() + first.dropFirst().lowercased()
        }
    }

    // MARK: - Age

    private func extractAge(from text: String, into detected: inout [String: String]) {
        let numberGroups = text.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .filter { !$0.isEmpty }

        // Direct numeric age (1-120)
        for group in numberGroups {
            if let num = Int(group), (1...120).contains(num) {
                detected["AGE"] = String(num)
                return
            }
        }

        // Birth year interpretation
        let currentYear = Calendar.current.component(.year, from: Date())
        for group in numberGroups {
            if let year = Int(group), (1930...(currentYear - 1)).contains(year) {
                detected["AGE"] = String(currentYear - year)
                return
            }
        }

        // Written number lookup (compound forms checked first via length sort)
        let lowercased = text.lowercased()
        let sorted = Self.writtenNumbers.sorted { $0.key.count > $1.key.count }
        for (word, value) in sorted where (1...120).contains(value) {
            if lowercased.contains(word) {
                detected["AGE"] = String(value)
                return
            }
        }
    }

    // MARK: - Job

    private func extractJob(from text: String, into detected: inout [String: String]) {
        let lowercased = text.lowercased()

        // Keyword matching with word boundaries
        for (keyword, job) in Self.jobKeywords {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
            if lowercased.range(of: pattern, options: .regularExpression) != nil {
                detected["JOB"] = job
                return
            }
        }

        // Fallback: accept raw text, filtering out stop words
        let words = text.split(separator: " ")
            .map(String.init)
            .filter { word in
                word.count >= 3
                    && word.allSatisfy { $0.isLetter || $0 == "-" }
                    && !Self.stopWords.contains(word.lowercased())
            }
        if !words.isEmpty {
            detected["JOB"] = words.joined(separator: " ")
        }
    }

    // MARK: - Contact

    private func extractContact(from text: String, into detected: inout [String: String]) {
        // Strict email regex
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        if let match = text.range(of: emailRegex, options: .regularExpression) {
            detected["EMAIL"] = String(text[match])
        }

        // Phone: must start/end with a digit, 8+ digits total
        let phoneRegex = "\\+?\\d[\\d\\s\\-().]{6,18}\\d"
        if let match = text.range(of: phoneRegex, options: .regularExpression) {
            let phoneStr = String(text[match])
            if phoneStr.filter({ $0.isNumber }).count >= 8 {
                detected["PHONE"] = phoneStr
            }
        }
    }
}
