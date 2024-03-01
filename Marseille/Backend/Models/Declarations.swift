//
//  Declarations.swift
//  Marseille
//
//  Created by Serena on 07/01/2023
//
	

import Foundation

/// Describes a declaration,
/// which is basically just an array of joined up syntax tokens lol
struct Declaration: Hashable, Codable {
    let tokens: [SyntaxToken]
    let platforms: [String]
}
