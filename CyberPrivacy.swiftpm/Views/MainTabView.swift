import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationView {
                AuditView()
            }
            .tabItem {
                Label("Audit", systemImage: "checklist")
            }
            
            NavigationView {
                PasswordLabView()
            }
            .tabItem {
                Label("Lab", systemImage: "flask.fill")
            }
            
            NavigationView {
                TipsView()
            }
            .tabItem {
                Label("Tips", systemImage: "lightbulb.fill")
            }
        }
        .accentColor(.blue) // Couleur globale des icônes de la TabView
    }
}
