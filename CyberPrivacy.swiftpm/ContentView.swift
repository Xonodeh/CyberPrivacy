import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var step: AppStep = .chat
    
    enum AppStep {
        case chat, terminal, mainApp
    }
    
    var body: some View {
        NavigationView {
            Group {
                switch step {
                case .chat:
                    ChatView(onFinish: {
                        withAnimation { step = .terminal }
                    })
                case .terminal:
                    TerminalView(onEnterApp: {
                        withAnimation { step = .mainApp }
                    })
                case .mainApp:
                    MainTabView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
