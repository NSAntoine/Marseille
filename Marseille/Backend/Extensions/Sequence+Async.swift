//
//  Sequence+Async.swift
//  Marseille
//
//  Created by Serena on 15/01/2023
//


import Foundation

extension Sequence {
    // async version of reduce
    @inlinable
    public func asyncReduce<Result>(
        into initialResult: __owned Result,
        _ updateAccumulatingResult:
        (_ partialResult: inout Result, Element) async throws -> Void
    ) async rethrows -> Result {
        var accumulator = initialResult
        
        for element in self {
            try await updateAccumulatingResult(&accumulator, element)
        }
        
        return accumulator
    }
}
