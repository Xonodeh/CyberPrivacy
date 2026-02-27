import SwiftUI
import Combine

@MainActor
class PasswordViewModel: ObservableObject {
    @Published var passwordToTest: String = ""
    @Published var strengthScore: Double = 0.0
    @Published var crackTime: String = "N/A"
    @Published var sha256Hash: String = ""

    private var cancellables = Set<AnyCancellable>()

    init() {
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

        let result = PasswordAnalyst.checkStrength(pass)
        strengthScore = result.score
        crackTime = result.time
        sha256Hash = result.hash
    }
}
