import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @AppStorage("hasCompletedChat") private var hasCompletedChat = false
    @State private var currentStep: AppStep = .chat

    enum AppStep {
        case chat, lock, mainApp
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            switch currentStep {
            case .chat:
                ChatView(onFinish: {
                    withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.5)) {
                        currentStep = .lock
                    }
                })
                .onAppear { viewModel.startConversation() }
                .transition(reduceMotion ? .opacity : .asymmetric(insertion: .scale(scale: 0.95).combined(with: .opacity), removal: .opacity))

            case .lock:
                LockTransitionView(onComplete: {
                    withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.8)) {
                        currentStep = .mainApp
                    }
                })
                .transition(.opacity)

            case .mainApp:
                MainTabView()
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            if hasCompletedChat {
                currentStep = .mainApp
            }
        }
        .onChange(of: hasCompletedChat) { completed in
            if !completed {
                viewModel.resetConversation()
                withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.5)) {
                    currentStep = .chat
                }
            }
        }
    }
}
