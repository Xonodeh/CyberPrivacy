import SwiftUI

struct ChatView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var isClosing = false
    var onFinish: () -> Void
    
    var body: some View {
        ZStack {
            // Fond principal
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // --- HEADER ---
                HStack {
                    Spacer()
                    Image(systemName: "swift")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.orange)
                        .padding(10)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CyberPrivacy AI")
                            .font(.system(.headline, design: .rounded))
                    }
                    Spacer()
                }
                .padding()
                .background(
                    Color(UIColor.systemBackground)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
                )
                .zIndex(1)
                
                // --- ZONE DE MESSAGES ---
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            Color.clear.frame(height: 10)
                            
                            ForEach(Array(viewModel.messages.enumerated()), id: \.offset) { index, msg in
                                ChatBubble(message: msg)
                                    .id(index)
                                    .transition(.scale.combined(with: .opacity)) // Transition plus visible
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .blur(radius: isClosing ? 15 : 0)
                    .onChange(of: viewModel.messages.count) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                }
                
                // --- BARRE D'ENTRÉE ---
                HStack {
                    TextField("Type your message...", text: $viewModel.currentInput)
                        .padding(12)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(20)
                        .disabled(isClosing)
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.sendMessage()
                        }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                    .disabled(viewModel.currentInput.isEmpty || isClosing)
                }
                .padding()
                .background(.ultraThinMaterial)
                .blur(radius: isClosing ? 15 : 0)

                // --- BOUTON FINAL ---
                if viewModel.isConversationFinished && !isClosing {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            isClosing = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            onFinish()
                        }
                    }) {
                        Text("PROTECT MY DATA")
                            .font(.caption.bold())
                            .tracking(1)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // --- OVERLAY DE PRÉVENTION ---
            if isClosing {
                VStack(spacing: 20) {
                    Image(systemName: "shield.slash.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("Privacy Warning")
                        .font(.title2.bold())
                    
                    Text("This conversation contained sensitive data that could be used to track or identify you. Always be cautious with AI.")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .padding(.horizontal, 40)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 25).fill(.ultraThinMaterial))
                .transition(.scale.combined(with: .opacity))
                .zIndex(2)
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let lastIndex = viewModel.messages.indices.last else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring()) {
                proxy.scrollTo(lastIndex, anchor: .bottom)
            }
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 50) // Pousse vers la droite
            }
            
            Text(message.text)
                .font(.body)
                .foregroundColor(message.isUser ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(message.isUser ? Color.blue : Color(UIColor.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            if !message.isUser {
                Spacer(minLength: 50) // Pousse vers la gauche
            }
        }
    }
}
