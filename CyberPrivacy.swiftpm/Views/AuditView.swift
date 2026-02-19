import SwiftUI

struct AuditView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var appeared = false
    @State private var selectedDefinition: Definition?

    private let definitions: [Definition] = [
        Definition(
            icon: "lock.shield.fill",
            color: .blue,
            term: "Hash",
            definition: "A one-way mathematical function that converts any input into a fixed-length string of characters. Even a tiny change in the input produces a completely different output.",
            example: "In the Password Lab, your password is hashed using SHA-256 — the app never sees your actual password.",
            detail: "Hashing is fundamental to modern security. Unlike encryption, hashing is irreversible — you can't \"un-hash\" something back to the original. Websites store hashed versions of your password, so even if their database is stolen, attackers only get meaningless strings. The same input always produces the same hash, which is how login verification works: the site hashes what you type and compares it to the stored hash.",
            examples: [
                "\"password123\" always hashes to the same SHA-256 output, but \"password124\" produces a completely different one.",
                "When LinkedIn was breached in 2012, 6.5 million password hashes were leaked — but poorly hashed (unsalted MD5), making them easy to crack.",
                "A \"salt\" is random data added before hashing, so even two users with the same password get different hashes."
            ]
        ),
        Definition(
            icon: "fish.fill",
            color: .red,
            term: "Phishing",
            definition: "A fraudulent attempt to steal sensitive information by disguising as a trustworthy entity, usually via email, text, or fake websites.",
            example: "The chatbot asked for your email \"to send a report\" — a classic phishing technique.",
            detail: "Phishing accounts for over 90% of data breaches. Attackers create convincing replicas of legitimate services — your bank, a delivery company, your employer — and use urgency or fear to push you into acting fast. Modern phishing goes beyond email: it includes SMS (smishing), voice calls (vishing), and even QR codes. The key defense is to never click links from unsolicited messages and always verify the sender independently.",
            examples: [
                "A fake \"Your account will be suspended\" email from what looks like Apple, but the sender domain is apple-security-verify.com.",
                "A QR code on a parking meter that redirects to a fake payment page stealing your card details.",
                "A phone call from \"your bank's fraud department\" asking you to confirm your PIN to \"secure your account\"."
            ]
        ),
        Definition(
            icon: "person.2.fill",
            color: .orange,
            term: "Social Engineering",
            definition: "The art of manipulating people into revealing confidential information by exploiting trust, curiosity, or fear — no hacking required.",
            example: "The entire chat you just had was a social engineering scenario: friendly questions that extracted your personal data.",
            detail: "Social engineering exploits the weakest link in any security system: human psychology. Attackers build rapport, create a sense of urgency, or impersonate authority figures to bypass technical defenses entirely. It's the reason companies get breached even with state-of-the-art firewalls — because someone was simply tricked into handing over credentials or clicking a link. It can happen to anyone, regardless of technical skill.",
            examples: [
                "An attacker calls IT support pretending to be a new employee who forgot their password, and gets a reset.",
                "A USB drive labeled \"Salary Report Q4\" left in a company parking lot — someone plugs it in, installing malware.",
                "A LinkedIn message from a fake recruiter asking you to open a \"job description\" PDF that contains malware."
            ]
        ),
        Definition(
            icon: "hammer.fill",
            color: .purple,
            term: "Brute Force",
            definition: "An attack method that systematically tries every possible combination of characters until the correct password is found.",
            example: "The Password Lab shows how long a brute-force attack would take to crack your password.",
            detail: "Brute force attacks are simple but powerful: try every combination until one works. Modern GPUs can test billions of password combinations per second. Short or simple passwords (like \"abc123\") fall in seconds. Longer passwords with mixed characters can take centuries. This is why password length matters more than complexity — each extra character multiplies the number of possible combinations exponentially. Rate limiting and account lockouts are the main defenses on the server side.",
            examples: [
                "A 6-character lowercase password has 308 million combinations — crackable in under 1 second by a modern GPU.",
                "A 12-character password with mixed case, numbers, and symbols has over 400 trillion combinations.",
                "Dictionary attacks are a smarter variant: instead of trying every combination, they try common words and passwords first."
            ]
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Cyber Basics")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(.primary)

                Text("Tap a card to dive deeper")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 8)

            // Flashcards
            TabView {
                ForEach(Array(definitions.enumerated()), id: \.element.term) { index, definition in
                    DefinitionCard(definition: definition, index: index, appeared: appeared, reduceMotion: reduceMotion) {
                        selectedDefinition = definition
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .onAppear {
            withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
        }
        .sheet(item: $selectedDefinition) { definition in
            DefinitionDetailView(definition: definition)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Data Model

private struct Definition: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let term: String
    let definition: String
    let example: String
    let detail: String
    let examples: [String]
}

// MARK: - Detail Sheet

private struct DefinitionDetailView: View {
    let definition: Definition

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(definition.color.opacity(0.15))
                            .frame(width: 56, height: 56)

                        Image(systemName: definition.icon)
                            .font(.system(size: 26))
                            .foregroundStyle(definition.color)
                    }
                    .accessibilityHidden(true)

                    Text(definition.term)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(.primary)
                }
                .padding(.top, 24)

                // Full explanation
                Text(definition.detail)
                    .font(.body)
                    .foregroundStyle(.primary.opacity(0.85))
                    .lineSpacing(4)

                // Examples
                VStack(alignment: .leading, spacing: 14) {
                    Text("Real-world examples")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    ForEach(Array(definition.examples.enumerated()), id: \.offset) { index, example in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(definition.color.opacity(0.8)))

                            Text(example)
                                .font(.subheadline)
                                .foregroundStyle(.primary.opacity(0.8))
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Example \(index + 1): \(example)")
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(UIColor.secondarySystemBackground))
                )

                // In-app callout
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.yellow)
                        .padding(.top, 2)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("In this app")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary)

                        Text(definition.example)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .accessibilityElement(children: .combine)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Flashcard Sub-View

private struct DefinitionCard: View {
    let definition: Definition
    let index: Int
    let appeared: Bool
    let reduceMotion: Bool
    let onTap: () -> Void

    @State private var cardAppeared = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 24) {
                Spacer()

                // Icon
                Image(systemName: definition.icon)
                    .font(.system(size: 56))
                    .foregroundStyle(definition.color)
                    .symbolRenderingMode(.hierarchical)
                    .scaleEffect(cardAppeared ? 1.0 : (reduceMotion ? 1.0 : 0.5))
                    .animation(
                        reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.6).delay(0.1),
                        value: cardAppeared
                    )
                    .accessibilityHidden(true)

                // Term
                Text(definition.term)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(.primary)

                // Definition
                Text(definition.definition)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)

                // Example callout
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.yellow)
                        .padding(.top, 2)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("In this app")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary)

                        Text(definition.example)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .accessibilityElement(children: .combine)

                // Tap hint
                HStack(spacing: 4) {
                    Text("Tap to learn more")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.tertiary)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
                .padding(.top, 4)

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(cardAppeared ? 1.0 : (reduceMotion ? 1.0 : 0.0))
        .scaleEffect(cardAppeared ? 1.0 : (reduceMotion ? 1.0 : 0.92))
        .onAppear {
            withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05)) {
                cardAppeared = true
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(definition.term). \(definition.definition)")
        .accessibilityHint("Double tap to learn more")
        .accessibilityAddTraits(.isButton)
    }
}
