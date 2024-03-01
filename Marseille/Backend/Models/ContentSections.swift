//
//  ContentSections.swift
//  Marseille
//
//  Created by Serena on 07/01/2023
//
	

import Foundation

struct PrimaryContentSection: Codable {
    let value: Value
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SectionCodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)
        
        switch kind {
        case "parameters":
            self.value = .parameters(try container.decode([Parameters].self, forKey: .parameters))
        case "declarations":
            self.value = .declarations(try container.decode([Declaration].self, forKey: .declarations))
        case "content":
            self.value = .content(try container.decode(Content.self, forKey: .content))
        case "details":
            self.value = .parameters([])
        default:
            throw Swift.DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [SectionCodingKeys.kind], debugDescription: "Expected kind to be one of 3: parameters, declarations, content, but instead we got \(kind).")
            )
        }
    }
    
    enum SectionCodingKeys: CodingKey {
        case kind
        case declarations
        case parameters
        case content
    }
    
    enum Value: Codable {
        case parameters([Parameters])
        case declarations([Declaration])
        case content(Content)
    }
}

/// Describes the relationship of one topic to another.
struct RelationshipSection: Codable {
    /// The title of the relationship, ie, 'Inherits From'
    let title: String
    
    /// The items relating to the relationship, stored as a String array of IDs.
    /// ie, 'doc://com.apple.documentation/documentation/uikit/uiresponder'
    let identifiers: [String]
}
