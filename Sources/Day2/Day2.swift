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
        reports.count(where: { report in
            let deltas = report.deltas()
            return deltas.isSafe
        })
    }
    
    private func part2(reports: [Report]) -> Int {
        reports.count(where: { report in
            let deltas = report.deltas()
            if deltas.isSafe {
                return true
            }
            
            return report.readings.indices.contains(where: { index in
                var newReadings = report.readings
                newReadings.remove(at: index)
                
                let report = Report(readings: newReadings)
                let deltas = report.deltas()
                return deltas.isSafe
            })
        })
    }
}

private struct Report: Equatable {
    let readings: [Int]
    
    func deltas() -> Deltas {
        Deltas(
            values: readings.windows(ofCount: 2).map({ window in
                window.last! - window.first!
            })
        )
    }
}

private struct Deltas {
    let values: [Int]
    
    var isSafe: Bool {
        var signums = Set<Int>()
        
        return values.allSatisfy({ value in
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
    
    func isSafeWithDamping() -> Bool {
        if isSafe {
            return true
        }
        
        return values.indexed().contains(where: { (index, delta) in
            var newValues = values
            newValues.remove(at: index)
            
            if index > values.startIndex, index != values.indices.last {
                newValues[index - 1] += delta
            }
            
            let newDeltas = Deltas(values: newValues)
            return newDeltas.isSafe
        })
    }
}

extension Report {
    init(rawValue: String) {
        self.readings = rawValue.components(separatedBy: " ").compactMap(Int.init)
    }
}
