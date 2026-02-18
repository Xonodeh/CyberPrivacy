import SwiftUI

struct TipsView: View {
    @State private var checkedTips: Set<Int> = []
    @State private var showCompletionBadge = false
    
    let tips: [(icon: String, title: String, description: String, tag: String, tagColor: Color)] = [
        ("exclamationmark.shield.fill", "Phishing Awareness", "Always verify sender addresses before clicking links.", "Most exploited", .red),
        ("eye.slash.fill", "Social Media Privacy", "Review your privacy settings regularly and limit what you share publicly.", "Most ignored", .orange),
        ("key.fill", "Strong Passwords", "Use unique passwords for each account and enable two-factor authentication.", "High risk", .red),
        ("icloud.slash.fill", "Public Wi-Fi Safety", "Avoid accessing sensitive accounts on public networks without a VPN.", "Frequently exploited", .orange)
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header avec insight
                    VStack(spacing: 12) {
                        Text("Security Tips")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        // 💡 INSIGHT FORT (1 phrase)
                        Text("Most hacks happen because of simple mistakes.")
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 40)
                    
                    // 🛡️ CHECKLIST INDICATOR
                    HStack(spacing: 8) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.green)
                        
                        Text("Good habits checklist")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("\(checkedTips.count)/\(tips.count)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(checkedTips.count == tips.count ? .green : .white.opacity(0.6))
                        
                        if checkedTips.count == tips.count {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.05))
                    )
                    .padding(.horizontal, 20)
                    
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
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if checkedTips.contains(index) {
                                            checkedTips.remove(index)
                                        } else {
                                            checkedTips.insert(index)
                                            // Haptic feedback
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()
                                            
                                            // Check si tous complétés
                                            if checkedTips.count == tips.count {
                                                let success = UINotificationFeedbackGenerator()
                                                success.notificationOccurred(.success)
                                                showCompletionBadge = true
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
            }
            
            // 🎉 COMPLETION BADGE (si 4/4)
            if showCompletionBadge {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.green)
                        
                        Text("All habits reviewed!")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
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
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            showCompletionBadge = false
                        }
                    }
                }
            }
        }
    }
}

struct TipCard: View {
    let icon: String
    let title: String
    let description: String
    let tag: String
    let tagColor: Color
    let isChecked: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isChecked ? .green.opacity(0.2) : .white.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.green)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 22))
                            .foregroundStyle(.white)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        // 🎯 MICRO TAG CONTEXTUEL
                        Text(tag)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(tagColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(tagColor.opacity(0.15))
                            )
                    }
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // 💡 MINI CTA
                    if !isChecked {
                        HStack(spacing: 4) {
                            Text("Tap to mark as read")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                            
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .padding(.top, 4)
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isChecked ? .green.opacity(0.05) : .white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                isChecked ? .green.opacity(0.3) : .white.opacity(0.1),
                                lineWidth: isChecked ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isChecked ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
