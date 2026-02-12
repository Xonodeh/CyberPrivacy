import SwiftUI

struct ChatView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    var onFinish: () -> Void
    
    var body: some View {
        ZStack {
            Color(white: 0.05).ignoresSafeArea() // Fond quasi noir
            
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(viewModel.messages) { message in
                                ChatBubble(message: message)
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .move(edge: .bottom)),
                                        removal: .opacity
                                    ))
                            }
                        }
                        .padding()
                    }
                }
                
                // Input "Glassmorphism"
                HStack {
                    TextField("", text: $viewModel.currentInput, prompt: Text("Écris ici...").foregroundColor(.gray))
                        .padding()
                        .background(.white.opacity(0.05))
                        .cornerRadius(15)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.sendMessage()
                        }
                    }) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.cyan)
                            .font(.title2)
                    }
                }
                .padding()
                .background(.ultraThinMaterial) // Effet flou iOS
                
                if !viewModel.extractedData.isEmpty {
                    Button(action: onFinish) {
                        Text("SÉCURITÉ COMPROMISE : VOIR")
                            .font(.caption.bold())
                            .tracking(2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.text)
                .padding(14)
                .background(message.isUser ? Color.cyan.opacity(0.2) : Color.white.opacity(0.1))
                .cornerRadius(20, corners: message.isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(message.isUser ? Color.cyan.opacity(0.5) : .clear, lineWidth: 1)
                )
                .foregroundColor(.white)
            if !message.isUser { Spacer() }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
