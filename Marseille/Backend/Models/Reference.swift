//
//  Reference.swift
//  Marseille
//
//  Created by Serena on 03/01/2023
//


import UIKit

/// A Reference to a page, usually represented in a `[String: Reference]` dictionary
/// where the key is the ID of the page,
/// and the value contains information such as the URL, title, etc.
struct Reference: Codable, Hashable {
	typealias Fragment = SyntaxToken
	
    /// The title of the reference, ie `SwiftUI`
    let title: String?
    
    /// An array of the descriptions
    let abstract: [AbstractDescription]?
    
    /// The fragments,
    /// containing each segment of declaration of the item this Reference is about.
    let fragments: [Fragment]?
    
    /// The type of this reference
    let type: RefType
    
	/// The role of this ref
//	let role: Role?
	
    /// The image variants, if this is an image
    let variants: [ImageVariant]?
    
    let url: String?
    
    /// The alt text, if this is an image.
    let alt: String?
    
	/// is this deprecated?
	let deprecated: Bool?
	
    /// The type of this reference
    enum RefType: String, Codable, Hashable {
        case topic
        case image
        case section
        case link
		case download
        case unresolvable // ???
    }
    
	/// The role of this reference,
	/// NOTE: The *role* is different than the *type*
	/// Think of it as: The role is what the purpose off this reference is,
	/// the type is for where this ref will lead to
	enum Role: String, Codable, Hashable {
		case symbol
		case collection
		case article
		case sampleCode
		case collectionGroup
		case link
		case overview
		case dictionarySymbol
	}
    
    struct ImageVariant: Codable, Hashable {
        let tags: [String]?
        let url: String
    }
    
    /// Returns the image variant that is suitable to use in user interface
    func suitableVariant() -> ImageVariant? {
        guard let variants else {
            return nil
        }
        
        let probablySuitable = variants.first { variant in
            return variant.tags?.contains(UITraitCollection.current.userInterfaceStyle.tagDescription) ?? false
        }
        
        return probablySuitable ?? variants.first
    }
}
