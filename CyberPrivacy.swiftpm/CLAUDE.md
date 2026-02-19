# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is a **Swift Playground App** (.swiftpm) targeting **iOS 16.0+**, using **Swift 6.0** and Swift Package Manager.

- **Swift Playgrounds:** Open `CyberPrivacy.swiftpm` directly
- **Xcode:** Open as Swift Package, run the `AppModule` scheme
- No external dependencies — uses only Apple frameworks (SwiftUI, Foundation, Combine, NaturalLanguage, CryptoKit, UIKit)
- No test target is configured

## Architecture

**MVVM** with a **Manager** service layer. The app is an educational cybersecurity awareness tool that walks users through a social engineering scenario, then reveals how their data was captured.

### Navigation Flow

`ContentView` orchestrates a linear multi-stage flow controlled by a `currentStep` enum:

1. **SplashScreenView** → 2-second intro
2. **ChatView** → 4-question social engineering chatbot that extracts personal data via NLP
3. **LockTransitionView** → Face ID → Lock morphing animation (3 seconds)
4. **MainTabView** → Three tabs: Audit (profiling results), Password Lab (strength tester), Tips (security checklist)

### State Management

- `ChatViewModel` is created as `@StateObject` in `MyApp` and passed via `@EnvironmentObject` throughout the app
- `PasswordViewModel` is local to `PasswordLabView`
- Both ViewModels use `@MainActor`

### Service Layer (Managers/)

| Manager | Purpose | Key Framework |
|---------|---------|---------------|
| `NLPManager` | Entity extraction (names, emails, phones, jobs) from chat input | NaturalLanguage (NLTagger) |
| `PasswordAnalyst` | Entropy calculation, brute-force time estimation, SHA-256 hashing | CryptoKit |
| `SecuritySanitizer` | Input validation (length, anti-spam, XSS) | Foundation |

### Key Patterns

- Haptic feedback used extensively via `UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator`
- Animations use spring physics and delayed transitions
- Code comments are in French
- Sub-components (ChatBubble, TerminalLine, TipCard) are defined within their parent view files
