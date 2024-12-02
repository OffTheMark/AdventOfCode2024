//
//  Day2.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-01.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Algorithms

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
        let reports = try readLines().map(Report.init)
        
        printTitle("Part 1", level: .title1)
        let numberOfSafeReports = part1(reports: reports)
        print("Safe reports:", numberOfSafeReports, terminator: "\n\n")
    }
    
    private func part1(reports: [Report]) -> Int {
        reports.count(where: \.isSafe)
    }
}

private struct Report {
    let readings: [Int]
    
    var isSafe: Bool {
        var signums = Set<Int>()
        
        for window in readings.windows(ofCount: 2) {
            let difference = window.last! - window.first!
            
            if !(1 ... 3).contains(abs(difference)) {
                return false
            }
            
            let signum = difference.signum()
            signums.insert(signum)
            
            if signums.count == 2 {
                return false
            }
        }
        
        return true
    }
}

extension Report {
    init(rawValue: String) {
        self.readings = rawValue.components(separatedBy: " ").compactMap(Int.init)
    }
}
