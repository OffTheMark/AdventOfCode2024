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
        let lines = try readLines()
        
    }
    
    func part1(inputs: [String]) -> Int {
        // TODO
        0
    }
    
    func part2(inputs: [String]) -> Int {
        // TODO
        0
    }
}
