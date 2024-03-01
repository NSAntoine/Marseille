//
//  Technologies.swift
//  Coirax
//
//  Created by Serena on 03/01/2023
//


import Foundation

/// The root object of the technologies page,
/// displaying the available, documented frameworks to browse through
struct Technologies: Codable, Hashable {
    
    /// The URL to fetch from the root technologies page.
    static var fetchURL: URL {
        URL.documentationBaseURL.appending("/documentation/technologies.json")
    }
    
    let sections: [Section]
    let references: [String: Reference]
    let diffAvailability: [String: AvailabilityDifference]
    
    struct Section: Codable, Hashable {
        let groups: [Group]?
    }
    
    struct Group: Codable, Hashable {
        let technologies: [Technology]
        let name: String
    }
    
    struct Technology: Codable, Hashable {
        let title: String
        let tags: Set<String>
        let destination: Destination
        
        struct Destination: Codable, Hashable {
            let identifier: String?
        }
    }
    
    /// The availability difference, used to track down the changes in previous & next documentation changes,
    struct AvailabilityDifference: Codable, Hashable, CustomStringConvertible {
        let platform: String
        let versions: [String]
        
        var description: String {
            return "\(platform) \(versions[0]) - \(versions[1])"
        }
    }
}
