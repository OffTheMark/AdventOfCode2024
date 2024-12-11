//
//  Day10.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-04.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections

struct Day10: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day10",
            abstract: "Solve day 10 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let grid = Grid2D<Int>(rawValue: try readFile()) {
            Int(String($0))
        }
        
        let clock = ContinuousClock()
        
        printTitle("Part 1", level: .title1)
        let (part1Duration, sumOfTrailheadScores) = clock.measure {
            part1(grid)
        }
        print("Sum of scores of all trailheads:", sumOfTrailheadScores)
        print("Elapsed time:", part1Duration, terminator: "\n\n")
    }
    
    func part1(_ grid: Grid2D<Int>) -> Int {
        let startingPoints: Set<Point2D> = grid.reduce(into: []) { result, element in
            let (point, height) = element
            if height == 0 {
                result.insert(point)
            }
        }
        var pathsByEnds = [PathEnds: Path]()
        let validMoves: [Translation2D] = [.up, .right, .down, .left]
        
        for startingPoint in startingPoints {
            var queue: Deque<Path> = [[startingPoint]]
            
            while let path = queue.popFirst() {
                let lastPoint = path.last!
                let height = grid[lastPoint]!
                
                if height == 9 {
                    let ends = PathEnds(start: path.first!, end: lastPoint)
                    
                    if let existingPath = pathsByEnds[ends] {
                        if existingPath.count < path.count {
                            pathsByEnds[ends] = path
                        }
                    }
                    else {
                        pathsByEnds[ends] = path
                    }
                    continue
                }
                
                moveLoop: for neighbor in validMoves.map({ lastPoint.applying($0) }) {
                    guard let nextHeight = grid[neighbor], nextHeight == height + 1 else {
                        continue moveLoop
                    }
                    
                    queue.append(path + [neighbor])
                }
            }
        }
        
        let scoresByTrailhead: [Point2D: Int] = pathsByEnds.keys.reduce(into: [:]) { result, ends in
            result[ends.start, default: 0] += 1
        }
        
        return scoresByTrailhead.values.reduce(0, +)
    }
}

private struct PathEnds: Hashable {
    let start: Point2D
    let end: Point2D
}

private typealias Path = [Point2D]
