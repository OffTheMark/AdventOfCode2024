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
        let updates: [Update] = parts[1]
            .components(separatedBy: .newlines)
            .map({ line in
                Update(pages: line.components(separatedBy: ",").compactMap(Int.init))
            })
        
        printTitle("Part 1", level: .title1)
        let (correctUpdates, incorrectUpdates) = partition(updates, accordingTo: rules)
        
        let sumOfMiddlePageNumbersOfCorrectUpdates = part1(correctUpdates: correctUpdates)
        print(
            "Sum of the middle page numbers of correctly-ordered updates:",
            sumOfMiddlePageNumbersOfCorrectUpdates,
            terminator: "\n\n"
        )
        
        printTitle("Part 2", level: .title1)
        let sumOfMiddlePageNumbersOfIncorrectUpdates = part2(rules: rules, incorrectUpdates: incorrectUpdates)
        print(
            "Sum of the middle page numbers of correctly-ordered updates after correctly ordering them:",
            sumOfMiddlePageNumbersOfIncorrectUpdates
        )
    }
    
    private func partition(_ updates: [Update], accordingTo rules: [Rule]) -> (correct: [Update], incorrect: [Update]) {
        var correctUpdates = [Update]()
        var incorrectUpdates = [Update]()
        
        for update in updates {
            let isCorrectlyOrdered = update.isCorrectlyOrdered(accordingTo: rules)
            
            if isCorrectlyOrdered {
                correctUpdates.append(update)
            }
            else {
                incorrectUpdates.append(update)
            }
        }
        
        return (correctUpdates, incorrectUpdates)
    }
    
    private func part1(correctUpdates: [Update]) -> Int {
        correctUpdates.reduce(into: 0, { result, update in
            result += update[update.pageCount / 2]
        })
    }
    
    private func part2(rules: [Rule], incorrectUpdates: [Update]) -> Int {
        incorrectUpdates.reduce(into: 0) { result, update in
            let previousPagesByPage: [Int: Set<Int>] = rules.reduce(into: [:]) { result, rule in
                guard rule.isApplicable(to: update) else {
                    return
                }
                
                result[rule.rhs, default: []].insert(rule.lhs)
            }
            
            if let middlePage = previousPagesByPage.first(where: { _, previousPages in
                previousPages.count == update.pageCount / 2
            })?.key {
                result += middlePage
            }
        }
    }
}

private struct Update {
    let pages: [Int]
    
    var pageCount: Int { pages.count }
    
    var distinctPages: Set<Int> { Set(pages) }
    
    func isCorrectlyOrdered(accordingTo rules: [Rule]) -> Bool {
        let applicableRules = rules.filter { rule in
            rule.isApplicable(to: self)
        }
        
        if applicableRules.isEmpty {
            return false
        }
        
        let offsetsByPageNumber = enumerated()
            .reduce(into: [Int: Int](), { result, pair in
                let (offset, pageNumber) = pair
                result[pageNumber] = offset
            })
        
        return applicableRules.allSatisfy { rule in
            let lhsOffset = offsetsByPageNumber[rule.lhs]!
            let rhsOffset = offsetsByPageNumber[rule.rhs]!
            
            return lhsOffset < rhsOffset
        }
    }
}

extension Update: Sequence {
    func makeIterator() -> IndexingIterator<[Int]> {
        pages.makeIterator()
    }
}

extension Update: Collection {
    var startIndex: Int { pages.startIndex }
    
    var endIndex: Int { pages.endIndex }
    
    func index(after i: Int) -> Int {
        pages.index(after: i)
    }
    
    subscript(index: Int) -> Int { pages[index] }
}

private struct Rule {
    let lhs: Int
    let rhs: Int
    
    var pages: Set<Int> { [lhs, rhs] }
    
    func isApplicable(to update: Update) -> Bool {
        update.distinctPages.isSuperset(of: pages)
    }
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
