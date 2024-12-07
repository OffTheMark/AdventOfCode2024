//
//  Day8.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-04.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import RegexBuilder
import Collections

struct Day7: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day7",
            abstract: "Solve day 7 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let equations = try readLines().compactMap(CalibrationEquation.init)
        
        printTitle("Part 1", level: .title1)
        let totalCalibrationResult = part1(equations)
        print("Total calibration result:", totalCalibrationResult, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let totalCalibrationResultWithConcatenation = part2(equations)
        print("Total calibration result allowing concatenation:", totalCalibrationResultWithConcatenation)
    }
    
    private func part1(_ equations: [CalibrationEquation]) -> Int {
        equations.reduce(into: 0, { sum, equation in
            if equation.canProduceTestValue(allowedOperations: [.add, .multiply]) {
                sum += equation.testValue
            }
        })
    }
    
    private func part2(_ equations: [CalibrationEquation]) -> Int {
        equations.reduce(into: 0, { sum, equation in
            if equation.canProduceTestValue(allowedOperations: Operation.allCases) {
                sum += equation.testValue
            }
        })
    }
}

private struct CalibrationEquation {
    let testValue: Int
    let numbers: [Int]
    
    func canProduceTestValue(allowedOperations: [Operation]) -> Bool {
        guard numbers.count >= 2 else {
            return false
        }
        
        var visited = Set<Node>()
        var stack: Deque<Node> = [Node(result: numbers[0], index: 0)]
        
        outer: while let current = stack.popLast() {
            if current.result > testValue {
                continue outer
            }
            
            visited.insert(current)
            
            if current.result == testValue, current.index == numbers.indices.last {
                return true
            }
            
            let nextIndex = current.index.advanced(by: 1)
            guard numbers.indices.contains(nextIndex) else {
                continue
            }
            
            for operation in allowedOperations {
                let nextResult = operation.perform(current.result, numbers[nextIndex])
                let nextNode = Node(result: nextResult, index: nextIndex)
                
                if nextResult <= testValue, !visited.contains(nextNode) {
                    let nextNode = Node(result: nextResult, index: nextIndex)
                    stack.append(nextNode)
                }
            }
        }
        
        return false
    }
    
    private struct Node: Hashable {
        let result: Int
        let index: Int
    }
}

extension CalibrationEquation {
    init?(rawValue: String) {
        let regex = Regex {
            let number = OneOrMore(.digit)
            
            TryCapture {
                number
            } transform: {
                Int(String($0))
            }
            
            ": "
            
            TryCapture {
                One(number)
                
                ZeroOrMore {
                    " "
                    number
                }
            } transform: {
                let parts = $0.components(separatedBy: " ")
                return parts.compactMap(Int.init)
            }
        }
        
        guard let match = rawValue.firstMatch(of: regex) else {
            return nil
        }
        
        self.testValue = match.output.1
        self.numbers = match.output.2
    }
}

private enum Operation: Hashable, CaseIterable {
    case add
    case multiply
    case concatenate
    
    func perform(_ lhs: Int, _ rhs: Int) -> Int {
        switch self {
        case .add:
            lhs + rhs
        case .multiply:
            lhs * rhs
        case .concatenate:
            Int(String(lhs) + String(rhs))!
        }
    }
}
