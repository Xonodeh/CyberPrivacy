import SwiftUI

struct SettingsView: View {
    @AppStorage("appearanceMode") private var appearanceMode: Int = 0
    @AppStorage("hasCompletedChat") private var hasCompletedChat = false
    @AppStorage("userName") private var userName = "friend"
    @Environment(\.dismiss) private var dismiss
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                // Appearance
                Section {
                    Picker(selection: $appearanceMode) {
                        Label("System", systemImage: "gear")
                            .tag(0)
                        Label("Light", systemImage: "sun.max.fill")
                            .tag(1)
                        Label("Dark", systemImage: "moon.fill")
                            .tag(2)
                    } label: {
                        Label("Appearance", systemImage: "circle.lefthalf.filled")
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Display")
                }

                // Reset experience
                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label("Redo the chat experience", systemImage: "arrow.counterclockwise")
                    }
                } header: {
                    Text("Experience")
                } footer: {
                    Text("Restart the social engineering scenario on next launch. Your current progress in labs and tips won't be affected.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .confirmationDialog(
                "Redo chat experience?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    hasCompletedChat = false
                    userName = "friend"
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("The chat scenario will play again on next launch.")
            }
        }
    }
}
