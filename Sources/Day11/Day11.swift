//
//  Day11.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-11.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections

struct Day11: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day11",
            abstract: "Solve day 11 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let input = try readFile()
    }
}
