//
//  Preferences.swift
//  Coirax
//
//  Created by Serena on 01/03/2024.
//  

import Foundation

enum Preferences {
    @RawValueStorage(key: "InterfaceLanguageToNavigateWith", defaultValue: .swift)
    static var interfaceLanguage: InterfaceLanguage
}
