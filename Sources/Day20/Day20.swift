//
//  Day20.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-19.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

struct Day20: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day20",
            abstract: "Solve day 20 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let input = try readFile()
    }
}
