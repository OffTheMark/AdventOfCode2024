//
//  Day10.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-10.
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
        
        printTitle("Map trails", level: .title1)
        let (mappingDuration, trails) = clock.measure {
            distinctTrails(in: grid)
        }
        print("Elapsed time:", mappingDuration, terminator: "\n\n")
        
        printTitle("Part 1", level: .title1)
        let sumOfTrailheadScores = part1(trails)
        print("Sum of scores of all trailheads:", sumOfTrailheadScores, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let sumOfTrailheadRatings = part2(trails)
        print("Sum of ratings of all trailheads:", sumOfTrailheadRatings)
    }
    
    private func distinctTrails(in grid: Grid2D<Int>) -> Set<Path> {
        let startingPoints: Set<Point2D> = grid.reduce(into: []) { result, element in
            let (point, height) = element
            if height == 0 {
                result.insert(point)
            }
        }
        var trails = Set<Path>()
        let validMoves: [Translation2D] = [.up, .right, .down, .left]
        
        for startingPoint in startingPoints {
            // Map all paths starting from each start point using breadth-first search (BFS)
            var queue: Deque<Path> = [[startingPoint]]
            
            while let path = queue.popFirst() {
                let lastPoint = path.last!
                let height = grid[lastPoint]!
                
                if height == 9 {
                    trails.insert(path)
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
        
        return trails
    }
    
    private func part1(_ trails: Set<Path>) -> Int {
        let distinctPathEnds: Set<PathEnds> = trails.reduce(into: []) { result, trail in
            let ends = PathEnds(start: trail.first!, end: trail.last!)
            result.insert(ends)
        }
        return distinctPathEnds.count
    }
    
    private func part2(_ trails: Set<Path>) -> Int {
        trails.count
    }
}

private struct PathEnds: Hashable {
    let start: Point2D
    let end: Point2D
}

private typealias Path = [Point2D]
