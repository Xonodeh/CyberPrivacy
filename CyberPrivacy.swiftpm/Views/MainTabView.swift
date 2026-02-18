//
//  MainTabView.swift
//  CyberPrivacy
//
//  Created by Nael on 12/02/2026.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // Premier onglet : Audit
            VStack {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                Text("Audit de Confidentialité")
                    .font(.title)
                    .padding()
                Text("Voici comment limiter la fuite de tes données personnelles sur internet.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .tabItem {
                Label("Audit", systemImage: "checklist")
            }
            
            // Deuxième onglet : Aide / Astuces
            VStack {
                Text("Guide de Protection")
                    .font(.title)
                List {
                    Section("Réseaux Sociaux") {
                        Text("Ne jamais mentionner sa ville en public.")
                        Text("Désactiver la géolocalisation des photos.")
                    }
                }
            }
            .tabItem {
                Label("Conseils", systemImage: "lightbulb")
            }
            //Troisème onglet
            PasswordLabView()
                .tabItem {
                    Label("Lab", systemImage: "flask.fill")
                }
        }
    }
}
