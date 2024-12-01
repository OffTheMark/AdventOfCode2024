//
//  Day1.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-11-25.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

struct Day1: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day1",
            abstract: "Solve day 1 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let lists = lists(from: try readLines())
        
        printTitle("Part 1", level: .title1)
        let totalDistance = part1(left: lists.left, right: lists.right)
        print("Total distance between lists:", totalDistance, terminator: "\n\n")
    }
    
    private func lists(from lines: [String]) -> (left: [Int], right: [Int]) {
        var left = [Int]()
        var right = [Int]()
        
        for line in lines {
            let parts = line.split(whereSeparator: \.isWhitespace).compactMap({ substring in
                Int(String(substring))
            })
            
            guard parts.count == 2 else {
                continue
            }
            
            left.append(parts[0])
            right.append(parts[1])
        }
        
        return (left, right)
    }
    
    func part1(left: [Int], right: [Int]) -> Int {
        let left = left.sorted()
        let right = right.sorted()
        
        return zip(left, right).reduce(into: 0, { result, pair in
            let (leftValue, rightValue) = pair
            result += abs(leftValue - rightValue)
        })
    }
    
    func part2(inputs: [String]) -> Int {
        // TODO
        0
    }
}
