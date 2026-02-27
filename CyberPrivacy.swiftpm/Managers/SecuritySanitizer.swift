import Foundation

struct SecuritySanitizer {

    // Validates input against spam, flooding, and minimum length
    static func isInputValid(_ input: String) -> Bool {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty { return false }
        if trimmed.count < 2 { return false }
        if trimmed.count > 200 { return false }

        // Reject repeated single-character spam (e.g. "aaaaa", "@@@@")
        let uniqueChars = Set(trimmed)
        if uniqueChars.count == 1 && trimmed.count > 2 { return false }

        return true
    }

    // Strips angle brackets to simulate basic XSS protection
    static func sanitize(_ input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let safe = trimmed.replacingOccurrences(of: "<", with: "")
                          .replacingOccurrences(of: ">", with: "")
        return safe
    }
}
