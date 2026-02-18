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
                                    .transition(.scale.combined(with: .opacity))
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
                        .disabled(isClosing || viewModel.isConversationFinished)
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.sendMessage()
                        }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                    .disabled(viewModel.currentInput.isEmpty || isClosing || viewModel.isConversationFinished)
                }
                .padding()
                .background(.ultraThinMaterial)
                .blur(radius: isClosing ? 15 : 0)

                // --- BOUTON FINAL STYLÉ ---
                if viewModel.isConversationFinished && !isClosing {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            isClosing = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onFinish()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text("Learn what you can do to stay safe")
                                .font(.system(size: 13, weight: .semibold))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                        .background(
                            Color.red
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.red.opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
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
                Spacer(minLength: 50)
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
                Spacer(minLength: 50)
            }
        }
    }
}
