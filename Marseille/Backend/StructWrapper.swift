//
//  StructWrapper.swift
//  Marseille
//
//  Created by Serena on 07/04/2023.
//  

import Foundation

// For the purposes of NSCache, which requires both types to be classes
class StructWrapper<Value> {
	let value: Value
	
	init(value: Value) {
		self.value = value
	}
}
