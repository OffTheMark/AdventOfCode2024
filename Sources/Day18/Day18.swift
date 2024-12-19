//
//  Day18.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-16.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections
import RegexBuilder

struct Day18: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day18",
            abstract: "Solve day 18 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let regex = Regex {
            let number = TryCapture {
                OneOrMore(.digit)
            } transform: {
                Int(String($0))
            }
            
            number
            ","
            number
        }
        let bytes: [Point2D] = try readLines().compactMap({ line in
            guard let match = line.firstMatch(of: regex) else {
                return nil
            }
            
            return Point2D(x: match.output.1, y: match.output.2)
        })
        let size = Size2D(width: 71, height: 71)
        let prefix = 1024
        
        let clock = ContinuousClock()
        printTitle("Part 1", level: .title1)
        let (part1Duration, minimumNumberOfStepsToExit) = clock.measure {
            part1(bytes: bytes, size: size, prefix: prefix)
        }
        print("Minimum number of steps to reach the exit:", minimumNumberOfStepsToExit)
        print("Elapsed time:", part1Duration, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        
        let (part2Duration, firstByteToPreventExit) = clock.measure {
            part2(bytes: bytes, size: size, prefix: prefix)
        }
        print("Coordinates of the first byte to prevent exit:", firstByteToPreventExit)
        print("Elapsed time:", part2Duration)
    }
    
    private func part1(bytes: [Point2D], size: Size2D, prefix: Int) -> Int {
        var grid = Grid2D<Tile>(frame: Frame2D(origin: .zero, size: size))
        for byte in bytes.prefix(prefix) {
            grid[byte] = .corrupted
        }
        
        let start = grid.frame.origin
        let end = Point2D(x: grid.frame.maxX, y: grid.frame.maxY)
        
        let shortestPath = dijkstra(from: start, to: end, in: grid)!
        return shortestPath.score
    }
    
    private func part2(bytes: [Point2D], size: Size2D, prefix: Int) -> String {
        var grid = Grid2D<Tile>(frame: Frame2D(origin: .zero, size: size))
        for byte in bytes.prefix(prefix) {
            grid[byte] = .corrupted
        }
        
        let start = grid.frame.origin
        let end = Point2D(x: grid.frame.maxX, y: grid.frame.maxY)
        
        let firstByte = bytes.dropFirst(prefix).first(where: { byte in
            grid[byte] = .corrupted
            
            let shortestPath = dijkstra(from: start, to: end, in: grid)
            return shortestPath == nil
        })!
        return "\(firstByte.x),\(firstByte.y)"
    }
    
    private func dijkstra(
        from start: Point2D,
        to end: Point2D,
        in grid: Grid2D<Tile>
    ) -> Node? {
        let startNode = Node(
            point: start,
            score: 0
        )
        
        var heap: Heap<Node> = [startNode]
        var visited = Set<Point2D>()
        var lowestScoreByPoint: [Point2D: Int] = [start: startNode.score]
        
        while let current = heap.popMin() {
            if current.point == end {
                return current
            }
            
            visited.insert(current.point)
            
            for neighbor in current.neighbors() {
                guard grid.isPointInside(neighbor.point),
                      grid[neighbor.point] != .corrupted,
                      !visited.contains(neighbor.point) else {
                    continue
                }
                
                let scoreToPoint = lowestScoreByPoint[neighbor.point, default: .max]
                
                if neighbor.score < scoreToPoint {
                    lowestScoreByPoint[neighbor.point] = neighbor.score
                    heap.insert(neighbor)
                }
            }
        }
        
        return nil
    }
}

private struct Node: Hashable, Comparable {
    let point: Point2D
    let score: Int
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.score < rhs.score
    }
    
    func neighbors() -> [Node] {
        let directions: [Translation2D] = [.up, .down, .left, .right]
        return directions.map({ translation in
            Self(
                point: point.applying(translation),
                score: score + 1
            )
        })
    }
}

private enum Tile: Character {
    case corrupted = "#"
}
