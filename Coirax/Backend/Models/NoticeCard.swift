//
//  NoticeCard.swift
//  Coirax
//
//  Created by Serena on 15/01/2023
//


import UIKit

/// Referred to as an 'aside' in the documentation JSONs,
/// this shows a notice, warning, or other type of crucial information
/// of the given API
struct NoticeCard: Codable, Hashable {
    let style: NoticeStyle
    let name: String?
    let content: Content
    
    enum NoticeStyle: String, Codable, Hashable, CustomStringConvertible {
        case important
        case warning
        case note
        
        var description: String {
            switch self {
            case .important:
                return "Important"
            case .warning:
                return "Warning"
            case .note:
                return "Note"
            }
        }
        
        /*
        var image: UIImage? {
            switch self {
            case .important:
                return UIImage(systemName: "exclamationmark")
            case .warning:
                return UIImage(systemName: "")
            }
            return nil
        }
         */
    }
}
