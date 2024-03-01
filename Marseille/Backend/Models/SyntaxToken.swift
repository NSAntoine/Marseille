//
//  SyntaxToken.swift
//  Marseille
//
//  Created by Serena on 07/01/2023
//


import UIKit

/// A structure describing a syntax token, used usually in a declaration,
/// For example, the following declaration:
/// `@frozen struct String`
///  would have 3 syntax tokens:
/// `@frozen`:  An attribute
/// `struct`:   A keyword
/// `String`:   The main identifier of this declaration
struct SyntaxToken: Codable, Hashable, AttributedTransformable {
	
	static let font = UIFont.monospacedSystemFont(ofSize: 18, weight: .regular)
	
    let kind: Kind
    let text: String
    let identifier: String?
    
    /// The kind of this Syntax Token
    enum Kind: String, Codable {
        /// Just plain text.
        case text
        
        /// A Keyword in the declaration, such as `func` or `init`
        case keyword
        
        /// Specified as the parameter name used in the function's inteface,
        /// such as the `with` in `func buy(with money: Int)`
        case externalParameter = "externalParam"
        
        /// Specified as the internal parameter name used in the function body,
        /// such as the `color` in func `didChange(to color: CodableColor)`
        case internalParameter = "internalParam"
        
        /// Specifies a type in a given declaration,
        /// such as the `Int` in `var amount: Int`
        case typeIdentifier
        
        /// The main identifier of the declaration,
        /// such as the `zero` in `static var zero: Self`
        case mainIdentifier = "identifier"
        
        /// An attribute in the declaration,
        /// such as the `@MainActor` in `@MainActor class UIView`
        case attribute
        
        /// A parameter representing a generic type.
        /// such as the
        case genericParameter
        
		case label
        
        /// A number, such as one used in an Enum case.
        /// ie,
        /// `case poof = 10`
        case number
		
		func color(context: Context) -> UIColor {
			switch self {
            case .text, .label, .genericParameter:
				return .secondaryLabel
            case .mainIdentifier, .externalParameter:
				return .tintColor
            case .keyword, .attribute:
				if context.isMakingAttributedStringForList {
					return .secondaryLabel
				}
				return .systemPink
			case .typeIdentifier:
                return #colorLiteral(red: 0.856077373, green: 0.7286333442, blue: 0.9990152717, alpha: 1)
			case .internalParameter:
				return .secondaryLabel
            case .number:
                return .systemYellow
			/* default:
				fatalError("Unknown type: \(self)")
             */
			}
        }
    }
    
	struct Context {
		let isMakingAttributedStringForList: Bool
        let refs: [String: Reference]?
        let font: UIFont?
        
        init(isMakingAttributedStringForList: Bool, refs: [String: Reference]? = nil, font: UIFont? = nil) {
            self.isMakingAttributedStringForList = isMakingAttributedStringForList
            self.refs = refs
            self.font = font
        }
	}
    
    func makeAttributedString(with context: Context) -> NSAttributedString {
        var dict: [NSAttributedString.Key: Any] = [.foregroundColor: kind.color(context: context), .font: context.font ?? Self.font]
        if let identifier = self.identifier, let url = context.refs?[identifier]?.url {
            dict[.link] = url
            dict[.underlineStyle] = NSUnderlineStyle.thick.rawValue
        }
        
        return NSAttributedString(
            string: text,
            attributes: dict
        )
    }
}
