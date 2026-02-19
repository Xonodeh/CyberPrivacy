import Foundation

struct DataSensitivityItem: Identifiable {
    let id = UUID()
    let dataLabel: String
    let context: String
    let isSensitive: Bool
    let explanation: String
}

struct DataSensitivityScenarios {
    static let all: [DataSensitivityItem] = [
        // Sensitive — Lock
        DataSensitivityItem(
            dataLabel: "Home address",
            context: "Shared in a public forum post",
            isSensitive: true,
            explanation: "Your home address can be used for stalking, identity theft, or targeted burglary. Never share it publicly."
        ),
        DataSensitivityItem(
            dataLabel: "Date of birth",
            context: "Displayed on your public social media profile",
            isSensitive: true,
            explanation: "Your birthday is used in security questions and identity verification. Combined with your name, it's a key piece for identity theft."
        ),
        DataSensitivityItem(
            dataLabel: "Mother's maiden name",
            context: "Answered in an online quiz game",
            isSensitive: true,
            explanation: "This is one of the most common security questions. Sharing it — even in a fun quiz — gives attackers a direct path into your accounts."
        ),
        DataSensitivityItem(
            dataLabel: "Phone number",
            context: "Listed on a public website",
            isSensitive: true,
            explanation: "Your phone number can be used for SIM swapping, spam calls, and bypassing two-factor authentication."
        ),
        DataSensitivityItem(
            dataLabel: "Passport photo",
            context: "Posted on Instagram as a travel throwback",
            isSensitive: true,
            explanation: "A passport contains your full name, nationality, date of birth, and a unique ID number — everything needed for identity fraud."
        ),
        DataSensitivityItem(
            dataLabel: "School name + graduation year",
            context: "Combined with your full name on a public profile",
            isSensitive: true,
            explanation: "This combo makes it easy to answer security questions, find your social circle, or craft convincing social engineering attacks."
        ),
        DataSensitivityItem(
            dataLabel: "Wi-Fi password",
            context: "Shared in a public group chat",
            isSensitive: true,
            explanation: "Anyone with your Wi-Fi password can access your home network, intercept traffic, and potentially reach your connected devices."
        ),

        // Harmless — Leak (it's fine)
        DataSensitivityItem(
            dataLabel: "Favorite color",
            context: "Shared in a casual conversation",
            isSensitive: false,
            explanation: "Your favorite color reveals nothing exploitable. It can't be used to access accounts or steal your identity."
        ),
        DataSensitivityItem(
            dataLabel: "Favorite movie",
            context: "Posted in a movie review group",
            isSensitive: false,
            explanation: "Movie preferences are harmless to share publicly. Just don't use them as answers to security questions!"
        ),
        DataSensitivityItem(
            dataLabel: "Shoe size",
            context: "Mentioned while shopping online with friends",
            isSensitive: false,
            explanation: "Your shoe size has no security value. No attacker can use it to compromise your accounts."
        ),
        DataSensitivityItem(
            dataLabel: "Favorite programming language",
            context: "Listed on your GitHub profile",
            isSensitive: false,
            explanation: "Technical preferences are safe to share. They're part of your professional identity, not your private data."
        ),
        DataSensitivityItem(
            dataLabel: "Music playlist",
            context: "Shared publicly on Spotify",
            isSensitive: false,
            explanation: "Your music taste is personal but not private. Sharing playlists poses no security risk."
        )
    ]

    static func randomSelection(count: Int = 6) -> [DataSensitivityItem] {
        // Ensure a mix of sensitive and harmless items
        let sensitive = all.filter { $0.isSensitive }.shuffled()
        let harmless = all.filter { !$0.isSensitive }.shuffled()
        let selected = Array(sensitive.prefix(3)) + Array(harmless.prefix(3))
        return selected.shuffled()
    }
}
