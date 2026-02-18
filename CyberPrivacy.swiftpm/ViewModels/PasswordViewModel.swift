//
//  PasswordViewModel.swift
//  CyberPrivacy
//
//  Created by Nael on 18/02/2026.
//

import SwiftUI
import Combine

@MainActor
class PasswordViewModel: ObservableObject {
    // Entrée utilisateur
    @Published var passwordToTest: String = ""
    
    // Sorties formatées pour la vue
    @Published var strengthScore: Double = 0.0
    @Published var crackTime: String = "N/A"
    @Published var sha256Hash: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // On observe les changements de passwordToTest pour mettre à jour l'analyse
        $passwordToTest
            .receive(on: RunLoop.main)
            .sink { [weak self] newValue in
                self?.analyzePassword(newValue)
            }
            .store(in: &cancellables)
    }
    
    private func analyzePassword(_ pass: String) {
        guard !pass.isEmpty else {
            strengthScore = 0.0
            crackTime = "N/A"
            sha256Hash = ""
            return
        }
        
        // Appel de la logique métier statique dans Managers
        let result = PasswordAnalyst.checkStrength(pass)
        
        strengthScore = result.score
        crackTime = result.time
        sha256Hash = result.hash
    }
}
