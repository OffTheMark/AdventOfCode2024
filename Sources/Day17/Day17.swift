//
//  Day65.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-16.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections
import RegexBuilder

struct Day17: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day17",
            abstract: "Solve day 17 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let input = try readFile()
    }
}
