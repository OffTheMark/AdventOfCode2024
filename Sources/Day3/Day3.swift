//
//  Day3.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-03.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Algorithms
import RegexBuilder

struct Day3: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day3",
            abstract: "Solve day 3 puzzle"
        )
    }
    
    @Argument(
        help: "Puzzle input path",
        transform: { URL(filePath: $0, relativeTo: nil) }
    )
    var puzzleInputURL: URL
    
    func run() throws {
        let input = try readFile()
        
        printTitle("Part 1", level: .title1)
        let sumOfProducts = part1(input)
        print("Sum of products:", sumOfProducts, terminator: "\n\n")
        
        printTitle("Part 1", level: .title1)
        let sumOfProductsOfEnabledMultiplications = part2(input)
        print("Sum of products of enabled multiplications:", sumOfProductsOfEnabledMultiplications)
    }
    
    func part1(_ input: String) -> Int {
        let multiplicationRegex = Regex {
            let number = TryCapture {
                OneOrMore(.digit)
            } transform: {
                Int(String($0))
            }
            
            "mul("
            number
            ","
            number
            ")"
        }
        
        return input.matches(of: multiplicationRegex).reduce(into: 0, { result, match in
            let product = match.output.1 * match.output.2
            result += product
        })
    }
    
    func part2(_ input: String) -> Int {
        let multiplicationRegex = Regex {
            let number = TryCapture {
                OneOrMore(.digit)
            } transform: {
                Int(String($0))
            }
            
            "mul("
            number
            ","
            number
            ")"
        }
        let enableRegex = Regex { "do()" }
        let disableRegex = Regex { "don't()" }
        
        var instructionsByOffset: [Int: Instruction] = input.matches(of: multiplicationRegex)
            .reduce(into: [:]) { result, match in
                let multiplication = Multiplication(lhs: match.output.1, rhs: match.output.2)
                let offset = input.distance(from: input.startIndex, to: match.range.lowerBound)
                result[offset] = .multiplication(multiplication)
            }
        for match in input.matches(of: enableRegex) {
            let offset = input.distance(from: input.startIndex, to: match.range.lowerBound)
            instructionsByOffset[offset] = .enableMultplication
        }
        for match in input.matches(of: disableRegex) {
            let offset = input.distance(from: input.startIndex, to: match.range.lowerBound)
            instructionsByOffset[offset] = .disableMultiplication
        }
        
        var result = 0
        var isMultiplicationEnabled = true
        
        for (_, instruction) in instructionsByOffset.sorted(using: KeyPathComparator(\.key)) {
            switch instruction {
            case .enableMultplication:
                isMultiplicationEnabled = true
                
            case .disableMultiplication:
                isMultiplicationEnabled = false
                
            case .multiplication(let multiplication):
                if !isMultiplicationEnabled {
                    continue
                }
                
                result += multiplication.product()
            }
        }
        
        return result
    }
}

private enum Instruction {
    case multiplication(Multiplication)
    case enableMultplication
    case disableMultiplication
}

private struct Multiplication {
    let lhs: Int
    let rhs: Int
    
    func product() -> Int {
        lhs * rhs
    }
}
