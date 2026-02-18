//
//  HeaderView.swift
//  CyberPrivacy
//
//  Created by Nael on 18/02/2026.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack(spacing: 16) {
            // Logo élégant avec dégradé
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [Color.blue, Color.cyan],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                
                // Icône shield (plus approprié pour CyberPrivacy)
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            // Titre avec spacing réduit
            Text("CyberPrivacy")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .kerning(-0.3) // Légèrement plus serré, style Apple
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 0, style: .continuous)
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color.primary.opacity(0.1)),
            alignment: .bottom
        )
    }
}
