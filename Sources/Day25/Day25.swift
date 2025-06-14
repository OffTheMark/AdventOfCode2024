//
//  Day25.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-25.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Algorithms

struct Day25: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day25",
            abstract: "Solve day 25 puzzle"
        )
    }
    
    @Argument(
        help: "Puzzle input path",
        transform: { URL(filePath: $0, relativeTo: nil) }
    )
    var puzzleInputURL: URL
    
    func run() throws {
        let (keys, locks) = try schematics()
        
        let clock = ContinuousClock()
        printTitle("Part 1", level: .title1)
        let (part1Duration, numberOfKeyLockCombinations) = clock.measure {
            part1(keys: keys, locks: locks)
        }
        print("Unique key/lock combinations:", numberOfKeyLockCombinations)
        print("Elapsed time:", part1Duration, terminator: "\n\n")
    }
    
    private func schematics() throws -> (keys: [Grid2D<Tile>], locks: [Grid2D<Tile>]) {
        let file = try readFile()
        
        let (keys, locks) = file.components(separatedBy: "\n\n")
            .reduce(into: (keys: [Grid2D<Tile>](), locks: [Grid2D<Tile>]())) { result, part in
                let grid = Grid2D<Tile>(rawValue: part)
                let gridPoints = Set(grid.points)
                
                let topRow = Set(grid.frame.columns.map({ Point2D(x: $0, y: grid.frame.minY) }))
                let bottomRow = Set(grid.frame.columns.map({ Point2D(x: $0, y: grid.frame.maxY) }))
                
                if gridPoints.isSuperset(of: topRow), gridPoints.isDisjoint(with: bottomRow) {
                    result.locks.append(grid)
                }
                if gridPoints.isSuperset(of: bottomRow), gridPoints.isDisjoint(with: topRow) {
                    result.keys.append(grid)
                }
            }
        return (keys, locks)
    }
    
    private func part1(keys: [Grid2D<Tile>], locks: [Grid2D<Tile>]) -> Int {
        product(keys, locks).count(where: { (key, lock) in
            Set(key.points).isDisjoint(with: lock.points)
        })
    }
}

private enum Tile: Character {
    case occupied = "#"
}
