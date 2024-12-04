//
//  Day5.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-04.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

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
        
    }
}
