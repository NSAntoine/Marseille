//
//  Content+AttributedString.swift
//  Coirax
//
//  Created by Serena on 16/01/2023
//

// Extensions to Content.EmbeddedContent.InlineContent & Content.Value
// to create NSAttributedStrings from them

import UIKit

extension Content.EmbeddedContent.InlineContent: AttributedTransformable {
    static let bodyFont = UIFont.preferredFont(forTextStyle: .body)
    
    func makeAttributedString(with: [String: Coirax.Reference]) -> NSAttributedString {
        switch self {
        case .text(let plainText):
            return NSAttributedString(string: plainText, attributes: [.font: Self.bodyFont])
        case .codeVoice(let code):
            return NSAttributedString(
                string: code,
                attributes: [.font: UIFont.monospacedSystemFont(ofSize: Self.bodyFont.pointSize, weight: .regular)]
            )
            
        case .emphasis(let inlineContent):
            let combined = inlineContent.reduce(into: NSMutableAttributedString()) { partialResult, content in
                partialResult.append(content.makeAttributedString(with: with))
            }
            
            let attr: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: Self.bodyFont.pointSize)
            ]
            
            combined.addAttributes(attr, range: NSMakeRange(0, combined.length))
            return combined
        case .reference(let embeddedContentRef):
            guard let completeRef = with[embeddedContentRef.identifier] else {
                print("embeddedContentRef.identifier: \(embeddedContentRef.identifier)")
                return NSAttributedString(string: embeddedContentRef.identifier)
            }
            
            URL.documentationBaseURL
            if !embeddedContentRef.isActive {
                return NSAttributedString(
                    string: completeRef.title!,
                    attributes: [.font: UIFont.monospacedSystemFont(ofSize: Self.bodyFont.pointSize, weight: .regular)]
                )
            }
            
            return NSAttributedString(
                string: completeRef.title!,
                attributes: [.link: completeRef.url!, .font: Self.bodyFont]
            )
            
        case .image(/*let identifier*/_):
            #warning("Add image support some day")
            return .init()
        }
    }
}

extension Content.Value: AttributedTransformable {
    func makeAttributedString(with context: TopicDocumentation) -> NSAttributedString {
        switch self {
        case .metadata(let header):
            return NSAttributedString(string: header.text + "\n", attributes: [.font: header.uiFont])
        case .content(let content):
            switch content.value {
            case .paragraph(let inlineContent):
                let combined = inlineContent.combiningAttributedStrings(with: context.references)
                return combined
            case .orderedList(let lists), .unorderedList(let lists):
                let paragraphStyle = NSMutableParagraphStyle
                    .default
                    .mutableCopy() as! NSMutableParagraphStyle
                
                paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15)]
                paragraphStyle.defaultTabInterval = 15
                paragraphStyle.firstLineHeadIndent = 0
                paragraphStyle.headIndent = 15
                
                let stringToReturn = NSMutableAttributedString(string: "\n")
                
                for list in lists {
                    let stringToAppend = list.content.values.combiningAttributedStrings(with: context)
                    
                    let bulletPoint = NSMutableAttributedString(
                        string: "•\t\(stringToAppend.string)\n",
                        attributes: [.paragraphStyle: paragraphStyle].merging(stringToAppend.attributes(at: 0, effectiveRange: nil)) { old, _ in
                            old
                        }
                    )

                    stringToReturn.append(bulletPoint)
                }
                
                return stringToReturn
            case .noticeCard(let card):
                
                fallthrough
            default:
                return .init()
            }
        }
    }
}
