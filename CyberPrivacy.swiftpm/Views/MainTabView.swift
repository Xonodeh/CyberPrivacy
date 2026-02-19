import SwiftUI

struct MainTabView: View {
    @State private var showSettings = false

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(showSettings: $showSettings)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                AuditView()
            }
            .tabItem {
                Label("Learn", systemImage: "book.fill")
            }

            NavigationStack {
                LabHubView()
            }
            .tabItem {
                Label("Lab", systemImage: "flask.fill")
            }

            NavigationStack {
                TipsView()
            }
            .tabItem {
                Label("Tips", systemImage: "lightbulb.fill")
            }
        }
        .accentColor(.blue)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}
