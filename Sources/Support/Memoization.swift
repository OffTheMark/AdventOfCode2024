//
//  Memoization.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-11.
//

import Foundation

func memoize<Input: Hashable, Output>(
    _ function: @escaping (Input) -> Output
) -> (Input) -> Output {
    var resultCache = [Input: Output]()

    return { input in
        if let cached = resultCache[input] {
            return cached
        }

        let result = function(input)
        resultCache[input] = result
        return result
    }
}

func recursiveMemoize<Input: Hashable, Output>(
    _ function: @escaping ((Input) -> Output, Input) -> Output
) -> (Input) -> Output {
    var resultCache = [Input: Output]()
    var memo: ((Input) -> Output)!
    
    memo = { input in
        if let cached = resultCache[input] {
            return cached
        }
        
        let result = function(memo, input)
        resultCache[input] = result
        return result
    }
    
    return memo
}
