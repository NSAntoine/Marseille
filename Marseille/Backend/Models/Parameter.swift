//
//  Parameter.swift
//  Marseille
//
//  Created by Serena on 07/01/2023
//
	

import Foundation

/// Represents a parameter.
struct Parameters: Codable, Hashable {
    let name: String
    let content: [Content.EmbeddedContent]
}
