//
//  Day6.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-04.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import RegexBuilder

struct Day6: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day6",
            abstract: "Solve day 6 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let input = try readFile()
        // TODO
    }
}
