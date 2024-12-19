//
//  Day19.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-16.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections
import RegexBuilder

struct Day19: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day19",
            abstract: "Solve day 19 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let input = Input(rawValue: try readFile())!
        
        let clock = ContinuousClock()
        printTitle("Part 1", level: .title1)
        let (part1Duration, numberOfPossibleDesigns) = clock.measure {
            part1(input)
        }
        print("Number of possible designs:", numberOfPossibleDesigns)
        print("Elapsed time:", part1Duration, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let (part2Duration, totalNumberOfWaysToMakeDesigns) = clock.measure {
            part2(input)
        }
        print("Total number of ways to make desired designs:", totalNumberOfWaysToMakeDesigns)
        print("Elapsed time:", part2Duration)
    }
    
    private func part1(_ input: Input) -> Int {
        input.desiredDesigns.count(where: { desiredDesign in
            isDesign(desiredDesign, possibleWith: input.availablePatterns)
        })
    }
    
    private func isDesign(_ design: String, possibleWith availablePatterns: Set<String>) -> Bool {
        let designCount = design.count
        
        let startNode = Node(
            slice: design.startIndex ..< design.startIndex,
            chosenPatterns: []
        )
        var stack: Deque<Node> = [startNode]
        var visited = Set<Node>()
        
        while let current = stack.popLast() {
            if current.slice == design.startIndex ..< design.endIndex {
                return true
            }
            
            guard !visited.contains(current) else {
                continue
            }
            
            let currentCount = design.distance(from: current.slice.lowerBound, to: current.slice.upperBound)
            
            visited.insert(current)
            
            for pattern in availablePatterns {
                let countAfterPattern = currentCount + pattern.count
                
                guard countAfterPattern <= designCount else {
                    continue
                }
                
                let endIndexAfterPattern = design.index(current.slice.upperBound, offsetBy: pattern.count)
                let substring = design[current.slice.upperBound ..< endIndexAfterPattern]
                
                guard substring == pattern else {
                    continue
                }
                
                let nextNode = Node(
                    slice: current.slice.lowerBound ..< endIndexAfterPattern,
                    chosenPatterns: current.chosenPatterns + [pattern]
                )
                
                stack.append(nextNode)
            }
        }
        
        return false
    }
    
    private func part2(_ input: Input) -> Int {
        let memoizedCombinations = recursiveMemoize { (numberOfCombinations: (String) -> Int, design: String) -> Int in
            if design.isEmpty {
                return 1
            }
            
            return input.availablePatterns.reduce(into: 0, { sum, pattern in
                guard design.starts(with: pattern) else {
                    return
                }
                
                let remaining = String(design.dropFirst(pattern.count))
                let countOfRemaining = numberOfCombinations(remaining)
                sum += countOfRemaining
            })
        }
        
        return input.desiredDesigns.reduce(into: 0) { sum, design in
            let combinations = memoizedCombinations(design)
            sum += combinations
        }
    }
}

private struct Node: Hashable {
    let slice: Range<String.Index>
    let chosenPatterns: [String]
}

private struct Input {
    let availablePatterns: Set<String>
    let desiredDesigns: [String]
}

extension Input {
    init?(rawValue: String) {
        let regex = Regex {
            let pattern = OneOrMore("a"..."z")
            
            TryCapture {
                pattern
                
                ZeroOrMore {
                    ", "
                    pattern
                }
            } transform: {
                Set(String($0).components(separatedBy: ", "))
            }
            
            "\n\n"
            TryCapture {
                pattern
                
                ZeroOrMore {
                    "\n"
                    pattern
                }
            } transform: {
                String($0).components(separatedBy: "\n")
            }
        }
        
        guard let match = rawValue.firstMatch(of: regex) else {
            return nil
        }
        
        self.availablePatterns = match.output.1
        self.desiredDesigns = match.output.2
    }
}
