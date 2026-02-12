//
//  ChatMessge.swift
//  CyberPrivacy
//
//  Created by Nael on 12/02/2026.
//

import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}
