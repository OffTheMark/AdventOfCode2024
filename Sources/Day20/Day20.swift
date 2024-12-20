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
    
    func run() throws {
        let grid = Grid2D<Tile>(rawValue: try readFile())
        
        let clock = ContinuousClock()
        printTitle("Part 1", level: .title1)
        let (part1Duration, numberOfCheatsSavingEnoughTime) = clock.measure {
            part1(grid)
        }
        print("Number of cheats that would save at least 100 picoseconds:", numberOfCheatsSavingEnoughTime)
        print("Elapsed time:", part1Duration, terminator: "\n\n")
    }
    
    private func part1(_ grid: Grid2D<Tile>) -> Int {
        let start = grid.points.first(where: { grid[$0] == .start })!
        let end = grid.points.first(where: { grid[$0] == .end })!
        let shortestPath = shortestPath(from: start, to: end, in: grid)
        
        print("Shortest path:", shortestPath)
        
        let cheatsSavingEnoughTime = cheats(
            savingAtLeast: 1,
            offShortestPath: shortestPath,
            from: start,
            to: end,
            in: grid
        )
        return cheatsSavingEnoughTime.count
    }
    
    private func shortestPath(
        from start: Point2D,
        to end: Point2D,
        in grid: Grid2D<Tile>
    ) -> Int {
        let startNode = Node(
            state: State(point: start),
            visited: [start],
            score: 0
        )
        var heap: Heap<Node> = [startNode]
        var lowestScoreByPoint: [Point2D: Int] = [startNode.point: startNode.score]
        let availableMoves: [Translation2D] = [.up, .right, .down, .left]
        
        while let current = heap.popMin() {
            if current.point == end {
                return current.score
            }
            
            for move in availableMoves {
                let nextPoint = current.point.applying(move)
                
                guard grid.isPointInside(nextPoint),
                      grid[nextPoint] != .wall,
                      !current.visited.contains(nextPoint) else {
                    continue
                }
                
                let nextNode = Node(
                    state: State(point: nextPoint),
                    visited: current.visited.union([nextPoint]),
                    score: current.score + 1
                )
                
                let shouldContinue = if let lowestScoreForPoint = lowestScoreByPoint[nextPoint] {
                    lowestScoreForPoint >= nextNode.score
                }
                else {
                    true
                }
                
                if shouldContinue {
                    lowestScoreByPoint[nextPoint] = nextNode.score
                    heap.insert(nextNode)
                }
            }
        }
        
        fatalError("Could not find shortest path")
    }
    
    private func cheats(
        savingAtLeast savedTime: Int,
        offShortestPath shortestPath: Int,
        from start: Point2D,
        to end: Point2D,
        in grid: Grid2D<Tile>
    ) -> Set<Node> {
        var cheats: Set<Node> = []
        let startNode = Node(
            state: State(point: start),
            visited: [start],
            score: 0
        )
        var heap: Heap<Node> = [startNode]
        var lowestScoreByState: [State: Int] = [startNode.state: startNode.score]
        let availableMoves: [Translation2D] = [.up, .right, .down, .left]
        
        while let current = heap.popMin() {
            if current.point == end {
                if current.score <= shortestPath - savedTime {
                    cheats.insert(current)
                    continue
                }
                
                break
            }
            
            let nextNodes: [Node] = availableMoves.compactMap { move in
                let nextPoint = current.state.point.applying(move)
                
                guard grid.isPointInside(nextPoint) else {
                    return nil
                }
                
                if grid[nextPoint] != .wall {
                    let nextNode = current.applying(move)
                    return nextNode
                }
                
                if !current.state.isCheating {
                    let nextNode = current.applying(move, byCheating: true)
                    return nextNode
                }
                    
                return nil
            }
            
            for nextNode in nextNodes {
                let nextState = nextNode.state
                
                let shouldContinue = lowestScoreByState[nextState, default: .max] >= nextNode.score
                if shouldContinue {
                    lowestScoreByState[current.state] = nextNode.score
                    heap.insert(nextNode)
                }
            }
        }
        
        return cheats
    }
}

private struct State: Hashable {
    let point: Point2D
    var cheatedPoint: Point2D?
    
    var isCheating: Bool { cheatedPoint != nil }
}

private struct Node: Hashable, Comparable {
    let state: State
    var point: Point2D { state.point }
    let visited: Set<Point2D>
    let score: Int
    
    func applying(_ translation: Translation2D, byCheating: Bool = false) -> Self {
        let nextPoint = point.applying(translation)
        let cheatedPoint: Point2D? = if byCheating, !state.isCheating {
            nextPoint
        }
        else {
            state.cheatedPoint
        }
        let nextState = State(
            point: nextPoint,
            cheatedPoint: cheatedPoint
        )
        return Self(
            state: nextState,
            visited: visited.union([nextPoint]),
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
