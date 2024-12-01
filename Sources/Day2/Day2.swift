//
//  Day2.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-01.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

struct Day2: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day2",
            abstract: "Solve day 2 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let lines = try readLines()
    }
}
