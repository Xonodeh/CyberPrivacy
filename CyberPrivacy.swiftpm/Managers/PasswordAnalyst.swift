//
//  PasswordAnalyst.swift
//  CyberPrivacy
//
//  Created by Nael on 18/02/2026.
//

import Foundation
import CryptoKit

struct PasswordAnalyst {
    static func checkStrength(_ pass: String) -> (score: Double, time: String, hash: String) {
        let length = Double(pass.count)
        var types: Double = 0
        
        if pass.range(of: "[a-z]", options: .regularExpression) != nil { types += 26 }
        if pass.range(of: "[A-Z]", options: .regularExpression) != nil { types += 26 }
        if pass.range(of: "[0-9]", options: .regularExpression) != nil { types += 10 }
        if pass.range(of: "[.!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil { types += 32 }
        
        // Calcul d'entropie simple : log2(types^length)
        let entropy = length * (log2(max(types, 1)))
        let score = min(entropy / 128.0, 1.0) // Score sur 1.0
        
        // Simulation du temps de cassage (basé sur 10 milliards de tentatives/sec)
        let combinations = pow(max(types, 1), length)
        let seconds = combinations / 10_000_000_000
        
        // Formatage intelligent du temps avec switch
        let timeStr: String = {
            switch seconds {
            case ..<1:
                return "Instantly"
                
            case 1..<60:
                return "\(Int(seconds)) seconds"
                
            case 60..<3_600:
                return "\(Int(seconds/60)) minutes"
                
            case 3_600..<86_400:
                return "\(Int(seconds/3_600)) hours"
                
            case 86_400..<2_592_000: // < 30 jours
                let days = Int(seconds / 86_400)
                return "\(days) day\(days > 1 ? "s" : "")"
                
            case 2_592_000..<31_536_000: // < 1 an
                let months = Int(seconds / 2_592_000)
                return "\(months) month\(months > 1 ? "s" : "")"
                
            case 31_536_000..<3_153_600_000: // < 100 ans
                let years = Int(seconds / 31_536_000)
                return "\(years) year\(years > 1 ? "s" : "")"
                
            case 3_153_600_000..<31_536_000_000: // < 1000 ans
                let centuries = Int(seconds / 3_153_600_000)
                return "\(centuries) centur\(centuries > 1 ? "ies" : "y")"
                
            case 31_536_000_000..<31_536_000_000_000: // < 1 million d'années
                let millennia = Int(seconds / 31_536_000_000)
                return "\(millennia) millennia"
                
            default: // Au-delà
                let years = seconds / 31_536_000
                return String(format: "%.2e years", years)
            }
        }()
        
        // Génération du Hash SHA-256 (Pour le côté technique)
        let data = Data(pass.utf8)
        let hash = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        
        return (score, timeStr, hash)
    }
}
