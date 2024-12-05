//
//  Day5.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-04.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import RegexBuilder

struct Day5: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day5",
            abstract: "Solve day 5 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let input = try readFile()
        let parts = input.components(separatedBy: "\n\n")
        let rules = parts[0].components(separatedBy: .newlines).compactMap(Rule.init)
        let updates: [[Int]] = parts[1]
            .components(separatedBy: .newlines)
            .map({ line in
                line.components(separatedBy: ",").compactMap(Int.init)
            })
        
        printTitle("Part 1", level: .title1)
        let sumOfMiddlePageNumbersOfCorrectUpdates = part1(rules: rules, updates: updates)
        print(
            "Sum of the middle page numbers of correctly-ordered updates:",
            sumOfMiddlePageNumbersOfCorrectUpdates,
            terminator: "\n\n"
        )
    }
    
    private func part1(rules: [Rule], updates: [[Int]]) -> Int {
        updates.reduce(into: 0, { result, update in
            let offsetsByPageNumber = update.enumerated().reduce(into: [Int: Int](), { result, pair in
                let (offset, pageNumber) = pair
                result[pageNumber] = offset
            })
            let applicableRules = rules.filter({ rule in
                offsetsByPageNumber.keys.contains(rule.lhs) && offsetsByPageNumber.keys.contains(rule.rhs)
            })
            
            let isCorrectlyOrdered = !applicableRules.isEmpty && applicableRules.allSatisfy({ rule in
                let lhsOffset = offsetsByPageNumber[rule.lhs]!
                let rhsOffset = offsetsByPageNumber[rule.rhs]!
                
                return lhsOffset < rhsOffset
            })
            
            if isCorrectlyOrdered {
                result += update[update.count / 2]
            }
        })
    }
}

private struct Rule {
    let lhs: Int
    let rhs: Int
    
    var numbers: Set<Int> { [lhs, rhs] }
}

extension Rule {
    init?(rawValue: String) {
        let regex = Regex {
            let number = TryCapture {
                OneOrMore(.digit)
            } transform: {
                Int(String($0))
            }
            
            number
            "|"
            number
        }
        
        guard let match = rawValue.firstMatch(of: regex) else {
            return nil
        }
        
        self.lhs = match.output.1
        self.rhs = match.output.2
    }
}
