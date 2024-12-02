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
        
        printTitle("Part 2", level: .title1)
        let numberOfSafeReportsWithDamping = part2(reports: reports)
        print("Safe reports with damping:", numberOfSafeReportsWithDamping)
    }
    
    private func part1(reports: [Report]) -> Int {
        reports.count(where: \.isSafe)
    }
    
    private func part2(reports: [Report]) -> Int {
        reports.count(where: \.isSafeWithDamping)
    }
}

private struct Report: Equatable {
    let readings: [Int]
    
    var isSafe: Bool {
        var signums = Set<Int>()
        
        let deltas = deltas()
        return deltas.allSatisfy({ value in
            if !(1 ... 3).contains(abs(value)) {
                return false
            }
            
            let signum = value.signum()
            signums.insert(signum)
            
            if signums.count == 2 {
                return false
            }
            
            return true
        })
    }
    
    var isSafeWithDamping: Bool {
        if isSafe {
            return true
        }
        
        return readings.indices.contains(where: { index in
            var newReadings = readings
            newReadings.remove(at: index)
            
            let report = Report(readings: newReadings)
            return report.isSafe
        })
    }
    
    func deltas() -> [Int] {
        readings.windows(ofCount: 2).map({ window in
            window.last! - window.first!
        })
    }
}

extension Report {
    init(rawValue: String) {
        self.readings = rawValue.components(separatedBy: " ").compactMap(Int.init)
    }
}
