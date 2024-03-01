//
//  AttributedTransformable.swift
//  Marseille
//
//  Created by Serena on 16/01/2023
//


import Foundation

protocol AttributedTransformable {
    associatedtype Context = Void
    
    func makeAttributedString(with context: Context) -> NSAttributedString
}

extension Array where Element: AttributedTransformable {
    func combiningAttributedStrings(with context: Element.Context) -> NSMutableAttributedString {
        return reduce(into: NSMutableAttributedString()) { partialResult, transformable in
            partialResult.append(transformable.makeAttributedString(with: context))
        }
    }
}
