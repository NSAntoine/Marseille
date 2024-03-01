//
//  URL.swift
//  Marseille
//
//  Created by Serena on 03/01/2023
//
	

import Foundation

extension URL: ExpressibleByStringLiteral {
    static var documentationBaseURL: URL {
        return "https://developer.apple.com/tutorials/data"
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)!
    }
    
    // this is here just to make code more readable,
    // `appendingPathComponent` is a long name.
    func appending(_ component: String) -> URL {
        appendingPathComponent(component)
    }
    
    func addingQueryItems(_ q: [URLQueryItem]) -> URL {
        var cmp = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        cmp.queryItems = q
        return cmp.url!
    }
    
    func constructDocumentationURL(forLanguage language: InterfaceLanguage) -> URL {
        let languageQueryItem = URLQueryItem(name: "language", value: language.rawValue)
        if #available(iOS 16, *) {
            return self.appending(queryItems: [languageQueryItem])
        }
        
        var components = URLComponents(url: self.deletingPathExtension().appendingPathExtension("json"), resolvingAgainstBaseURL: false)!
        components.queryItems = [languageQueryItem]
        return components.url!
    }
    
    func standardizeDocSchemeURL() -> URL {
        let absStr = self.absoluteString
            .replacingOccurrences(of: "doc://com.apple.documentation", with: "")
        return URL.documentationBaseURL.appending(absStr).appendingPathExtension("json")
    }
}
