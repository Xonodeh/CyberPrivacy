//
//  ChatViewModel.swift
//  CyberPrivacy
//
//  Created by Nael on 12/02/2026.
//

import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var extractedData: [String: String] = [:]
    
    private let nlpManager = NLPManager()
    
    @MainActor
    func sendMessage() {
        guard !currentInput.isEmpty else { return }
        
        let userMsg = ChatMessage(text: currentInput, isUser: true)
        messages.append(userMsg)
        
        let found = nlpManager.extractEntities(from: currentInput)
        
        withAnimation {
            extractedData.merge(found) { (_, new) in new }
        }
        
        currentInput = ""
        
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000) // Attend 0.6 sec
            let botMsg = ChatMessage(text: "Analyse des métadonnées en cours...", isUser: false)
            self.messages.append(botMsg)
        }
    }
}
