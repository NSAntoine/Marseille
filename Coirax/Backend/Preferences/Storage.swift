//
//  Storage.swift
//  Coirax
//
//  Created by Serena on 01/03/2024.
//  

import Foundation

@propertyWrapper
class Storage<Value> {
    let key: String
    let defaultValue: Value
    
    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: Value {
        get {
            UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
class CodableStorage<Value: Codable>: Storage<Value> {
    override var wrappedValue: Value {
        get {
            guard let data = UserDefaults.standard.data(forKey: key),
                    let decoded = try? JSONDecoder().decode(Value.self, from: data) else { return defaultValue }
            return decoded
        }
        
        set {
            if let encoded = try? JSONEncoder().encode(newValue) { UserDefaults.standard.set(encoded, forKey: key) }
        }
    }
}

@propertyWrapper
class RawValueStorage<Value: RawRepresentable>: Storage<Value> {
    override var wrappedValue: Value {
        get {
            guard let rawValue = UserDefaults.standard.object(forKey: key) as? Value.RawValue else {
                return defaultValue
            }
            
            return Value(rawValue: rawValue) ?? defaultValue
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
}
