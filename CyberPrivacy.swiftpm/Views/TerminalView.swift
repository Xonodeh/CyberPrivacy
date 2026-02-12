//
//  TerminalView.swift
//  CyberPrivacy
//
//  Created by Nael on 12/02/2026.
//

import SwiftUI

struct TerminalView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    var onEnterApp: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // En-tête Terminal
                HStack {
                    Circle().fill(Color.red).frame(width: 12, height: 12)
                    Circle().fill(Color.yellow).frame(width: 12, height: 12)
                    Circle().fill(Color.green).frame(width: 12, height: 12)
                    Spacer()
                    Text("root@cyber-privacy: ~")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 10)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("> INITIALIZING DATA EXTRACTION...")
                            .foregroundColor(.green)
                        
                        Text("> EXTRACTED_JSON_OBJECT:")
                            .foregroundColor(.blue)
                        
                        // Affichage des données en format JSON brut
                        Text(formatAsJSON(viewModel.extractedData))
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                        
                        Text("> WARNING: Unencrypted sensitive data detected.")
                            .foregroundColor(.red)
                            .padding(.top)
                    }
                }
                
                Spacer()
                
                Button(action: onEnterApp) {
                    Text("Comment me protéger ?")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
    
    // Petite fonction pour simuler un affichage JSON
    func formatAsJSON(_ dict: [String: String]) -> String {
        let lines = dict.map { "  \"\($0.key)\": \"\($0.value)\"" }
        return "{\n\(lines.joined(separator: ",\n"))\n}"
    }
}
