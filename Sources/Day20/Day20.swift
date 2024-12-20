//
//  Day20.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-19.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections

struct Day20: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day20",
            abstract: "Solve day 20 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    @Option(name: .shortAndLong, help: "Threshold")
    var threshold: Int
    
    func run() throws {
        let grid = Grid2D<Tile>(rawValue: try readFile())
        
        let clock = ContinuousClock()
        printTitle("Part 1", level: .title1)
        let (part1Duration, numberOfCheatsSavingEnoughTime) = clock.measure {
            part1(grid)
        }
        print("Number of cheats that would save at least \(threshold) picoseconds:", numberOfCheatsSavingEnoughTime)
        print("Elapsed time:", part1Duration, terminator: "\n\n")
    }
    
    private func part1(_ grid: Grid2D<Tile>) -> Int {
        let start = grid.points.first(where: { grid[$0] == .start })!
        let end = grid.points.first(where: { grid[$0] == .end })!
        
        let clock = ContinuousClock()
        let (pathDuration, shortestPath) = clock.measure {
            self.shortestPath(from: start, to: end, in: grid)!
        }
        print("Shortest path:", shortestPath.score)
        print("Elapsed time:", pathDuration)
        
        let cheatsSavingEnoughTime = cheats(
            ofLength: 2,
            savingAtLeast: threshold,
            alongside: shortestPath,
            from: start,
            to: end,
            in: grid
        )
        return cheatsSavingEnoughTime
    }
    
    private func shortestPath(
        from start: Point2D,
        to end: Point2D,
        in grid: Grid2D<Tile>
    ) -> Node? {
        let startNode = Node(
            point: start,
            path: [start],
            score: 0
        )
        var queue: Deque<Node> = [startNode]
        var visited = Set<Point2D>()
        var lowestScoreByPoint: [Point2D: Int] = [startNode.point: startNode.score]
        let availableMoves: [Translation2D] = [.up, .right, .down, .left]
        
        while let current = queue.popFirst() {
            if current.point == end {
                return current
            }
            
            visited.insert(current.point)
            
            for move in availableMoves {
                let nextPoint = current.point.applying(move)
                
                guard grid.isPointInside(nextPoint),
                      grid[nextPoint] != .wall,
                      !visited.contains(nextPoint) else {
                    continue
                }
                
                let nextNode = Node(
                    point: nextPoint,
                    path: current.path + [nextPoint],
                    score: current.score + 1
                )
                
                let shouldContinue = lowestScoreByPoint[nextPoint, default: .max] >= nextNode.score
                if shouldContinue {
                    lowestScoreByPoint[nextPoint] = nextNode.score
                    queue.append(nextNode)
                }
            }
        }
        
        return nil
    }
    
    private func cheats(
        ofLength cheatLength: Int,
        savingAtLeast savedTime: Int,
        alongside node: Node,
        from start: Point2D,
        to end: Point2D,
        in grid: Grid2D<Tile>
    ) -> Int {
        var cheats = 0
        
        for (distance, point) in node.path.enumerated().dropLast(savedTime) {
            for (index, jumpedPoint) in node.path[(distance + savedTime)...].enumerated() {
                let manhattanDistance = point.manhattanDistance(to: jumpedPoint)
                
                if manhattanDistance <= cheatLength, manhattanDistance <= index {
                    cheats += 1
                }
            }
        }
        
        return cheats
    }
}

private struct Node: Hashable, Comparable {
    let point: Point2D
    let path: [Point2D]
    let score: Int
    
    func applying(_ translation: Translation2D) -> Self {
        let nextPoint = point.applying(translation)
        return Self(
            point: nextPoint,
            path: path + [nextPoint],
            score: score + 1
        )
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.score < rhs.score
    }
}

private enum Tile: Character {
    case start = "S"
    case end = "E"
    case wall = "#"
}
