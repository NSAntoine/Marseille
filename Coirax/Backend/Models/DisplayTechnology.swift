//
//  DisplayTechnology.swift
//  Coirax
//
//  Created by Serena on 04/01/2023
//
	

import Foundation

/// A Technology to be displayed in the UI
/// NOTE: this type isn't fetched but rather manually constructed
struct DisplayTechnology: Hashable {
    let tech: Technologies.Technology
    let reference: Reference
}
