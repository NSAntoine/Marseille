//
//  TopicDocumentation.swift
//  Coirax
//
//  Created by Serena on 07/01/2023
//


import Foundation

/// Describes the full information about a topic's documentation
struct TopicDocumentation: Codable {
    let variants: [TopicVariant]
    let metadata: Metadata
    let abstract: [AbstractDescription]?
    let primaryContentSections: [PrimaryContentSection]?
    let relationshipsSections: [RelationshipSection]?
    let references: [String: Reference]
    let identifier: TopicIdentifier
    let topicSections: [TopicSection]?
    
    struct Metadata: Codable {
        /// The title of the item, ie, `CGPoint` or `init(_:)`
        let title: String
        //let role: String
        /// The role heading of the item, such as `Associated Type` or `Instance Property`
        let roleHeading: String?
        /// The modules associated, such as `[Foundation]` or `[UIKit, AppKit]`
        let modules: [Module]?
        //let symbolKind: SymbolKind?
        let platforms: [Platform]?
    }
    
    struct TopicSection: Codable {
        let title: String
        let identifiers: [String]
		let abstract: [AbstractDescription]?
    }
    
    struct TopicIdentifier: Codable {
        let interfaceLanguage: String
    }
    
    struct TopicVariant: Codable {
        let traits: [VariantTrait]
        let paths: [String]
        
        struct VariantTrait: Codable {
            let interfaceLanguage: String
        }
    }
}

struct Module: Codable {
    let name: String
}
