import SwiftUI

struct AuditView: View {
    @State private var showContent = false
    @State private var glitchOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24) {
                    Image(systemName: "eye.trianglebadge.exclamationmark.fill")
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(.red)
                        .opacity(showContent ? 1.0 : 0.0)
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .offset(x: glitchOffset)
                    
                    VStack(spacing: 16) {
                        Text("You've Been Profiled")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(x: glitchOffset)
                        
                        Text("In under 3 minutes, an AI learned who you are, what you do, and how to target you.")
                            .font(.system(size: 17))
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, 40)
                            .opacity(showContent ? 1.0 : 0.0)
                    }
                }
                .padding(.bottom, 60)
                
                VStack(alignment: .leading, spacing: 12) {
                    TerminalLine(icon: "person.fill", label: "Identity", value: "CAPTURED", delay: 0.5)
                    TerminalLine(icon: "briefcase.fill", label: "Occupation", value: "LOGGED", delay: 0.7)
                    TerminalLine(icon: "calendar", label: "Age", value: "STORED", delay: 0.9)
                    TerminalLine(icon: "envelope.fill", label: "Contact", value: "INDEXED", delay: 1.1)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.red.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .opacity(showContent ? 1.0 : 0.0)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Text("You don't need a hacker. Your data speaks for itself.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .opacity(showContent ? 1.0 : 0.0)
                    
                    Button(action: {
                        // Navigation action
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "shield.lefthalf.filled")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text("Learn How to Protect Yourself")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundStyle(.black)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(color: .white.opacity(0.3), radius: 20, x: 0, y: 10)
                    }
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1.0 : 0.0)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                showContent = true
            }
            
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                withAnimation(.linear(duration: 0.05)) {
                    glitchOffset = CGFloat.random(in: -3...3)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.linear(duration: 0.05)) {
                        glitchOffset = 0
                    }
                }
            }
            
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        }
    }
}

struct TerminalLine: View {
    let icon: String
    let label: String
    let value: String
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.red)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 15, design: .monospaced))
                .foregroundStyle(.white.opacity(0.7))
            
            Spacer()
            
            HStack(spacing: 8) {
                Circle()
                    .fill(.red)
                    .frame(width: 6, height: 6)
                    .opacity(isVisible ? 1.0 : 0.0)
                
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(.red)
            }
        }
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(x: isVisible ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(delay)) {
                isVisible = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let impact = UINotificationFeedbackGenerator()
                impact.notificationOccurred(.warning)
            }
        }
    }
}
