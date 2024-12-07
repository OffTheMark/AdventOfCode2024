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

struct Day8: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day8",
            abstract: "Solve day 8 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let input = try readFile()
    }
}
