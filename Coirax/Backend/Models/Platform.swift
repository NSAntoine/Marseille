//
//  Platform.swift
//  Coirax
//
//  Created by Serena on 07/01/2023
//

import UIKit

/// Describes a platform given in a documentation document.
struct Platform: Codable, Hashable, CustomStringConvertible {
    /// The name of the platform
    let name: String
    
    /// The version that the symbol was introduced in
    let introducedAt: String
    
    /// The version that this symbol was deprecated in, if deprecated
    let deprecatedAt: String?
    
    var description: String {
        var description = "Name: \(name), Introduced In: \(introducedAt)"
        if let deprecatedAt {
            description.append(", Deprecated in \(deprecatedAt)")
        }
        return description
    }
    
    var image: UIImage? {
        switch name {
        case "iOS":
            return UIImage(systemName: "iphone")
        case "tvOS":
            return UIImage(systemName: "tv")
        case "watchOS":
            return UIImage(systemName: "applewatch")
        case "macOS":
            return UIImage(systemName: "laptopcomputer")
		case "Mac Catalyst":
			if #available(iOS 16, *) {
				return UIImage(systemName: "laptopcomputer.and.ipad")
			}
			
			return UIImage(systemName: "laptopcomputer")
        case "Xcode":
            return UIImage(systemName: "hammer")
        case "SwiftPM":
            return UIImage(systemName: "shippingbox")
		case "iPadOS":
			return UIImage(systemName: "ipad.landscape")
        case "visionOS":
            return UIImage(systemName: "visionpro")
        default:
            return nil
        }
    }
}
