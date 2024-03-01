//
//  InterfaceLanguage.swift
//  Coirax
//
//  Created by Serena on 01/03/2024.
//  

import Foundation

enum InterfaceLanguage: String, Codable {
    case swift
    case objc = "occ"
    
    var displayName: String {
        switch self {
        case .swift:
            return "Swift"
        case .objc:
            return "Objective-C"
        }
    }
    
    init?(rawValue: String) {
        switch rawValue {
        case "swift":
            self = .swift
        case "objc", "occ":
            self = .objc
        default:
            return nil
        }
    }
}
