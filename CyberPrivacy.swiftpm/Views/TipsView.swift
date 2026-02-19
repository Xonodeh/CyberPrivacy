import SwiftUI

struct TipsView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var checkedTips: Set<Int> = []
    @State private var showCompletionBadge = false
    @State private var selectedTipIndex: SelectedTip?

    private struct SelectedTip: Identifiable {
        let id: Int
    }

    let tips: [(icon: String, title: String, description: String, tag: String, tagColor: Color, detail: String, examples: [String])] = [
        (
            "exclamationmark.shield.fill",
            "Phishing Awareness",
            "Always verify sender addresses before clicking links.",
            "Most exploited", .red,
            "Phishing is the #1 method hackers use to steal credentials. Attackers craft emails, texts, or messages that look legitimate — from your bank, employer, or a popular service — to trick you into clicking a malicious link or entering your password on a fake site.",
            [
                "An email from \"support@paypa1.com\" (with a '1' instead of 'l') asking you to verify your account.",
                "A text saying \"Your package is held at customs\" with a suspicious short link.",
                "A fake login page that looks exactly like your email provider but has a slightly different URL."
            ]
        ),
        (
            "eye.slash.fill",
            "Social Media Privacy",
            "Review your privacy settings regularly and limit what you share publicly.",
            "Most ignored", .orange,
            "Oversharing on social media gives attackers everything they need for social engineering. Your birthday, pet's name, school, workplace, and vacation dates can be used to guess passwords, answer security questions, or plan targeted attacks.",
            [
                "Posting your boarding pass reveals your full name, booking reference, and travel dates.",
                "Sharing your birthday publicly gives attackers an answer to a common security question.",
                "Posting \"On vacation for 2 weeks!\" tells burglars your home is empty."
            ]
        ),
        (
            "key.fill",
            "Strong Passwords",
            "Use unique passwords for each account and enable two-factor authentication.",
            "High risk", .red,
            "Reusing passwords is one of the most dangerous habits online. When one service gets breached, attackers try those same credentials on every other platform. A password manager generates and stores unique, complex passwords so you don't have to remember them.",
            [
                "The 2019 Collection #1 breach exposed 773 million email/password combinations — all tested against banking sites.",
                "\"qwerty123\" can be cracked in under 1 second by a modern GPU.",
                "Two-factor authentication blocks 99.9% of automated attacks even if your password is stolen."
            ]
        ),
        (
            "icloud.slash.fill",
            "Public Wi-Fi Safety",
            "Avoid accessing sensitive accounts on public networks without a VPN.",
            "Frequently exploited", .orange,
            "Public Wi-Fi networks (cafes, airports, hotels) are easy targets for man-in-the-middle attacks. An attacker on the same network can intercept unencrypted traffic, capture login cookies, or set up a fake hotspot with a legitimate-sounding name.",
            [
                "A hacker creates a hotspot named \"Starbucks_Free_WiFi\" — your phone auto-connects because it looks familiar.",
                "On an unencrypted network, an attacker can see every HTTP request you make in real-time.",
                "Using a VPN encrypts all your traffic, making it unreadable even on a compromised network."
            ]
        ),
        (
            "bubble.left.and.exclamationmark.bubble.right.fill",
            "AI & Chatbot Privacy",
            "Never share personal data with AI agents or chatbots you don't fully trust.",
            "Emerging threat", .purple,
            "AI chatbots can feel like a safe space — they're friendly, conversational, and seem trustworthy. But anything you type can be stored, analyzed, or leaked. Just like this app showed you, a few casual questions are enough to build a complete profile: your name, age, job, and contact info — all in under a minute.",
            [
                "This app's chatbot extracted your personal data in 4 simple questions — and you gave it willingly.",
                "Some AI services store conversations indefinitely and may use them to train future models.",
                "A chatbot asking for your email \"to send a report\" is the same trick phishing emails use — creating a reason to hand over data."
            ]
        )
    ]

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header avec insight
                    VStack(spacing: 12) {
                        Text("Security Tips")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Text("Most hacks happen because of simple mistakes.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 30)

                    // CHECKLIST INDICATOR
                    HStack(spacing: 8) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.green)
                            .accessibilityHidden(true)

                        Text("Good habits checklist")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text("\(checkedTips.count)/\(tips.count)")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(checkedTips.count == tips.count ? .green : .secondary)

                        if checkedTips.count == tips.count {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .padding(.horizontal, 20)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(checkedTips.count) of \(tips.count) completed")

                    // Tips Cards
                    VStack(spacing: 16) {
                        ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                            TipCard(
                                icon: tip.icon,
                                title: tip.title,
                                description: tip.description,
                                tag: tip.tag,
                                tagColor: tip.tagColor,
                                isChecked: checkedTips.contains(index),
                                reduceMotion: reduceMotion,
                                onTap: {
                                    selectedTipIndex = SelectedTip(id: index)
                                },
                                onCheck: {
                                    withAnimation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7)) {
                                        if checkedTips.contains(index) {
                                            checkedTips.remove(index)
                                        } else {
                                            checkedTips.insert(index)
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()

                                            if checkedTips.count == tips.count {
                                                let success = UINotificationFeedbackGenerator()
                                                success.notificationOccurred(.success)
                                                showCompletionBadge = true
                                                UIAccessibility.post(notification: .announcement, argument: "All habits reviewed")
                                            }
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: 600)
            }
            .frame(maxWidth: .infinity)

            // Completion badge (si 4/4)
            if showCompletionBadge {
                VStack {
                    Spacer()

                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.green)

                        Text("All habits reviewed!")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.green)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.green.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.green, lineWidth: 2)
                            )
                    )
                    .shadow(color: .green.opacity(0.3), radius: 20, x: 0, y: 10)
                    .padding(.bottom, 40)
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(reduceMotion ? .none : .default) {
                            showCompletionBadge = false
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedTipIndex) { selected in
            let index = selected.id
            TipDetailView(
                icon: tips[index].icon,
                title: tips[index].title,
                description: tips[index].description,
                detail: tips[index].detail,
                examples: tips[index].examples,
                tagColor: tips[index].tagColor,
                isChecked: checkedTips.contains(index),
                reduceMotion: reduceMotion,
                onCheck: {
                    withAnimation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7)) {
                        if checkedTips.contains(index) {
                            checkedTips.remove(index)
                        } else {
                            checkedTips.insert(index)
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()

                            if checkedTips.count == tips.count {
                                let success = UINotificationFeedbackGenerator()
                                success.notificationOccurred(.success)
                                showCompletionBadge = true
                                UIAccessibility.post(notification: .announcement, argument: "All habits reviewed")
                            }
                        }
                    }
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Tip Detail View (Sheet)

struct TipDetailView: View {
    let icon: String
    let title: String
    let description: String
    let detail: String
    let examples: [String]
    let tagColor: Color
    let isChecked: Bool
    let reduceMotion: Bool
    let onCheck: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(tagColor.opacity(0.15))
                            .frame(width: 56, height: 56)

                        Image(systemName: icon)
                            .font(.system(size: 26))
                            .foregroundStyle(tagColor)
                    }
                    .accessibilityHidden(true)

                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                }
                .padding(.top, 24)

                // Description
                Text(detail)
                    .font(.body)
                    .foregroundStyle(.primary.opacity(0.85))
                    .lineSpacing(4)

                // Exemples
                VStack(alignment: .leading, spacing: 14) {
                    Text("Real-world examples")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    ForEach(Array(examples.enumerated()), id: \.offset) { index, example in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(tagColor.opacity(0.8)))

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

                // Mark as read button
                Button(action: onCheck) {
                    HStack(spacing: 10) {
                        Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))

                        Text(isChecked ? "Marked as read" : "Mark as read")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(isChecked ? .green : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(isChecked ? .green.opacity(0.1) : Color(UIColor.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(isChecked ? .green.opacity(0.4) : Color(UIColor.separator), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 4)
                .accessibilityValue(isChecked ? "Checked" : "Unchecked")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Tip Card

struct TipCard: View {
    let icon: String
    let title: String
    let description: String
    let tag: String
    let tagColor: Color
    let isChecked: Bool
    let reduceMotion: Bool
    let onTap: () -> Void
    let onCheck: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isChecked ? .green.opacity(0.2) : Color(UIColor.secondarySystemBackground))
                        .frame(width: 50, height: 50)

                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.green)
                            .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 22))
                            .foregroundStyle(.primary)
                    }
                }
                .accessibilityHidden(true)

                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Spacer()

                        // Micro tag contextuel
                        Text(tag)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(tagColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(tagColor.opacity(0.15))
                            )
                    }

                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 4) {
                        Text(isChecked ? "Tap for details" : "Tap to learn more")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.tertiary)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                            .accessibilityHidden(true)
                    }
                    .padding(.top, 4)
                }

                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isChecked ? .green.opacity(0.05) : Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                isChecked ? .green.opacity(0.3) : Color(UIColor.separator),
                                lineWidth: isChecked ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isChecked ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(tag). \(description)")
        .accessibilityValue(isChecked ? "Read" : "Unread")
        .accessibilityHint("Double tap to learn more")
        .accessibilityAddTraits(.isButton)
    }
}
