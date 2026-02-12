//
//  NLPManager.swift
//  CyberPrivacy
//
//  Created by Nael on 12/02/2026.
//

import Foundation
import NaturalLanguage

class NLPManager {
    func extractEntities(from text: String) -> [String: String] {
        var detected: [String: String] = [:]
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag {
                let value = String(text[tokenRange])
                switch tag {
                case .personalName: detected["Identité"] = value
                case .placeName: detected["Localisation"] = value
                case .organizationName: detected["Organisation"] = value
                default: break
                }
            }
            return true
        }
        return detected
    }
}
