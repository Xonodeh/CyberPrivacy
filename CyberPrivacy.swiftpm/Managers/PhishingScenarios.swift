import Foundation

struct PhishingScenario: Identifiable {
    let id = UUID()
    let sender: String
    let subject: String
    let body: String
    let isPhishing: Bool
    let explanation: String
    let redFlags: [String]
}

struct PhishingScenarios {
    static let all: [PhishingScenario] = [
        // 1. Phish — Fake PayPal
        PhishingScenario(
            sender: "support@paypa1.com",
            subject: "Your account has been compromised!",
            body: "We detected unusual activity on your account. Click below immediately to verify your identity or your account will be permanently suspended.",
            isPhishing: true,
            explanation: "This is a classic phishing email using urgency and fear to trick you into clicking a malicious link.",
            redFlags: [
                "Misspelled sender: \"paypa1\" instead of \"paypal\"",
                "Creates urgency: \"immediately\" and \"permanently suspended\"",
                "Asks you to click a link to \"verify\" your identity"
            ]
        ),

        // 2. Legit — Apple receipt
        PhishingScenario(
            sender: "no-reply@apple.com",
            subject: "Your receipt from Apple",
            body: "Your subscription to iCloud+ (50 GB) has been renewed. Amount charged: $0.99. To view your receipt, open the App Store app and tap your profile icon.",
            isPhishing: false,
            explanation: "This is a legitimate Apple receipt. It comes from the official domain, references a specific service, and directs you to the App Store app — not a link.",
            redFlags: []
        ),

        // 3. Phish — Package scam SMS
        PhishingScenario(
            sender: "+1 (555) 012-3456",
            subject: "SMS: Package held at customs",
            body: "USPS: Your package is being held due to unpaid customs fees ($1.99). Pay now to avoid return: https://usps-deliver.xyz/pay",
            isPhishing: true,
            explanation: "Delivery scams are extremely common. Real carriers don't text random links for small fees.",
            redFlags: [
                "Suspicious short link: \"usps-deliver.xyz\" is not a USPS domain",
                "Asks for payment through a text message link",
                "USPS does not collect customs fees via SMS"
            ]
        ),

        // 4. Legit — School email
        PhishingScenario(
            sender: "admin@lincoln-highschool.edu",
            subject: "Schedule change for Monday",
            body: "Dear students, please note that Monday's assembly has been moved from 9:00 AM to 10:30 AM due to the gym renovation. Check the school portal for the updated schedule.",
            isPhishing: false,
            explanation: "This is a routine school announcement from an official .edu domain. It doesn't ask for personal information or contain suspicious links.",
            redFlags: []
        ),

        // 5. Phish — Fake Netflix
        PhishingScenario(
            sender: "security@netflix-account-verify.com",
            subject: "Action Required: Password Reset",
            body: "Someone tried to access your Netflix account from a new device. If this wasn't you, reset your password immediately by clicking here.",
            isPhishing: true,
            explanation: "The sender domain is not Netflix's real domain. Legitimate Netflix emails come from @netflix.com only.",
            redFlags: [
                "Fake domain: \"netflix-account-verify.com\" is not netflix.com",
                "Creates fear: \"someone tried to access your account\"",
                "Vague \"click here\" link instead of directing to the official app"
            ]
        ),

        // 6. Legit — Bank statement
        PhishingScenario(
            sender: "notifications@chase.com",
            subject: "Your January statement is ready",
            body: "Your monthly statement for account ending in *4821 is now available. Log in to the Chase app or chase.com to view it. Do not reply to this email.",
            isPhishing: false,
            explanation: "This is a standard bank notification. It doesn't include links in the message, references a partial account number, and directs you to log in through official channels.",
            redFlags: []
        ),

        // 7. Phish — Gift card scam
        PhishingScenario(
            sender: "rewards@amazon-prizes.net",
            subject: "Congratulations! You won a $500 gift card!",
            body: "You've been selected as this month's winner! Claim your $500 Amazon gift card now. Just confirm your shipping address and pay $4.99 for delivery.",
            isPhishing: true,
            explanation: "\"You won\" emails are almost always scams. Amazon doesn't run random prize giveaways from unofficial domains.",
            redFlags: [
                "Fake domain: \"amazon-prizes.net\" is not amazon.com",
                "\"You've been selected\" — classic bait tactic",
                "Asks for a small payment to \"claim\" the prize"
            ]
        ),

        // 8. Legit — Doctor appointment
        PhishingScenario(
            sender: "no-reply@myclinic-health.com",
            subject: "Appointment reminder for Feb 24",
            body: "Hi, this is a reminder that you have an appointment with Dr. Martinez on Monday, February 24 at 2:00 PM. Please call (555) 234-5678 if you need to reschedule.",
            isPhishing: false,
            explanation: "This is a standard appointment reminder. It contains specific details, provides a phone number (not a link), and doesn't ask for personal information.",
            redFlags: []
        )
    ]

    /// Picks a random selection of scenarios for a game round
    static func randomSelection(count: Int = 4) -> [PhishingScenario] {
        Array(all.shuffled().prefix(count))
    }
}
