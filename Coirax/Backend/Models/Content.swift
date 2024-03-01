//
//  Content.swift
//  Coirax
//
//  Created by Serena on 15/01/2023
//


import UIKit

struct Content: Codable, Hashable {
    let values: [Value]
    
    struct HeaderMetadata: Codable, Hashable {
        let anchor: String
        let text: String
        let level: Int
        let type: String
        
        var uiFont: UIFont {
            switch level {
            case 2:
                return .preferredFont(forTextStyle: .largeTitle)
            case 3:
                return .preferredFont(forTextStyle: .subheadline)
            default:
                print("default called")
                return .preferredFont(forTextStyle: .title1)
            }
        }
    }
    
    // this is needed so that the order between metadata and content is known
    // when iterating over the contents of the struct.
    // What i mean is, if the struct just had:
    // let metadata: [Metadata]
    // let embedded: [EmbeddedContent]
    // Then you wouldn't know where to put the
    // and not identified by a key
    enum Value: Codable, Hashable {
        case metadata(HeaderMetadata)
        case content(EmbeddedContent)
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var values: [Value] = []
        
        while !container.isAtEnd {
            if let metadata = try? container.decode(HeaderMetadata.self) {
                values.append(.metadata(metadata))
            } else if let content = try? container.decode(EmbeddedContent.self) {
                values.append(.content(content))
            }
        }
        
        self.values = values
    }
    
	struct EmbeddedContent: Codable, Hashable, AttributedTransformable {
        func makeAttributedString(with context: [String: Coirax.Reference]) -> NSAttributedString {
			switch value {
            case .paragraph(let inlineContent), .termList(let inlineContent):
                return inlineContent.combiningAttributedStrings(with: context)
			default:
				fatalError()
			}
			
//			fatalError()
		}
		
        let value: ContentType
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: SpecializedCodingKeys.self)
            let stringType = try container.decode(ContentType.CodingKeys.self, forKey: .type)
            
            switch stringType {
            case .paragraph:
                let inlineContent = try container.decode([InlineContent].self, forKey: .inlineContent)
                self.value = .paragraph(inlineContent)
            case .codeListing:
                let code = try container.decode([String].self, forKey: .code)
                let syntaxLanguage = try container.decode(String.self, forKey: .syntax)
                self.value = .codeListing(CodeListing(code: code, syntaxLanguage: syntaxLanguage))
            case .orderedList:
                self.value = .orderedList(try container.decode([List].self, forKey: .items))
            case .unorderedList:
                self.value = .unorderedList(try container.decode([List].self, forKey: .items))
            case .noticeCard:
                let notice = NoticeCard(style: try container.decode(NoticeCard.NoticeStyle.self, forKey: .style),
                           name: try container.decodeIfPresent(String.self, forKey: .name),
                           content: try container.decode(Content.self, forKey: .content))
                self.value = .noticeCard(notice)
            case .termList:
                let inlineContent = try container.decode([InlineContent].self, forKey: .inlineContent)
                self.value = .termList(inlineContent) //todo etc
            case .table:
                self.value = .table //TODO: - handling for tables
            }
        }
        
        /// Represents a list of items.
        struct List: Codable, Hashable {
            let content: Content
        }
        
        // need to specialize because if we just override CodingKeys with these
        // we will get a compiler error
        enum SpecializedCodingKeys: String, CodingKey {
            case style
            case type
            case inlineContent, content
            case code, syntax
            case items
            case name
        }
        
        enum ContentType: Codable, Hashable {
            case paragraph([InlineContent])
            case codeListing(CodeListing)
            case table
            case termList([InlineContent])
            case orderedList([List])
            case unorderedList([List])
            // this is like one of those warnings
            // ie the one on
            // https://developer.apple.com/documentation/swift/string/init(bytesnocopy:length:encoding:freewhendone:)
            case noticeCard(NoticeCard) /* = "aside"*/
            
            enum CodingKeys: String, Codable, CodingKey {
                case paragraph
                case codeListing
                case table
                case orderedList
                case unorderedList
                case noticeCard = "aside"
                case termList
            }
        }
        
        /// Represents the type of inline content
        indirect enum InlineContent: Codable, Hashable {
            /// Just plain text
            case text(String)
            
            /// A `codeVoice` is just a mini-codeblock, like typing `something` in Markdown.
            case codeVoice(String)
            
            /// A reference, with a given ID to use in order to look up the item
            /// in References dictionary.
            /// In UI, this should be represented as clickable blue text,
            /// which redirects you to the page of the reference.
            case reference(Reference)
            
            /// Emphasized just means inline content which is italic.
            case emphasis([InlineContent])
            
            /// An image, with a given identifier.
            case image(identifier: String)
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: SpecializedCodingKeys.self)
                let type = try container.decode(CodingKeys.self, forKey: .type) // hahaha.. kill me
                switch type {
                case .text:
                    self = .text(try container.decode(String.self, forKey: .text))
                case .codeVoice:
                    self = .codeVoice(try container.decode(String.self, forKey: .code))
                case .reference:
                    self = .reference(Reference(
                        isActive: try container.decode(Bool.self, forKey: .isActive),
                        identifier: try container.decode(String.self, forKey: .identifier))
                    )
                case .emphasis:
                    self = .emphasis(try container.decode([InlineContent].self, forKey: .inlineContent))
                case .image:
                    self = .image(identifier: try container.decode(String.self, forKey: .identifier)) // todo: maybe add the image data lol
                }
            }
            
            enum SpecializedCodingKeys: String, CodingKey {
                case type
                case text
                case code
                case isActive
                case identifier
                case inlineContent // ironic..
            }
            
            enum CodingKeys: String, Codable, CodingKey {
                case text
                case codeVoice
                case reference
                case emphasis
                case image
            }
        }
        
        struct Reference: Codable, Hashable {
            /// Is the reference active?
            let isActive: Bool
            /// The id of the reference to look up in the References dictionary,
            /// ie "doc://com.apple.documentation/documentation/foundation/nsnumber/1413324-unsignedintegervalue"
            let identifier: String
        }
        
        /// Represents code shown, with syntax highlighting of the given language
        struct CodeListing: Codable, Hashable {
            // the code
            let code: [String]
            // language of the syntax
            let syntaxLanguage: String
            
            enum CodingKeys: String, CodingKey {
                case code
                case syntaxLanguage = "syntax"
            }
        }
    }
}


extension NSTextAttachment {
    func setImageHeight(height: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height
        
        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: ratio * height, height: height)
    }
}
