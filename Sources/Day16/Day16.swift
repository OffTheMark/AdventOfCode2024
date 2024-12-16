//
//  Day65.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-16.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections
import RegexBuilder

struct Day16: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day16",
            abstract: "Solve day 16 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let grid = Grid2D<Tile>(rawValue: try readFile())
        let start = grid.points.first(where: { grid[$0] == .start })!
        let end = grid.points.first(where: { grid[$0] == .end })!
        
        let clock = ContinuousClock()
        printTitle("Mapping shortest paths", level: .title1)
        let (mappingDuration, result) = clock.measure {
            shortestPaths(from: start, to: end, in: grid)
        }
        print("Elapsed time:", mappingDuration, terminator: "\n\n")
        
        printTitle("Part 1", level: .title1)
        print("Lowest score:", result.lowestScore, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let bestSeatCount = result.paths
            .reduce(into: Set<Point2D>()) { result, path in
                result.formUnion(path.visited.map(\.point))
            }
            .count
        print("Lowest score:", bestSeatCount)
    }
    
    private func shortestPaths(
        from start: Point2D,
        to end: Point2D,
        in grid: Grid2D<Tile>
    ) -> (lowestScore: Int, paths: Set<Node>) {
        let startState = State(point: start, direction: .right)
        let startNode = Node(
            state: startState,
            visited: [startState],
            score: 0
        )
        
        var heap: Heap<Node> = [startNode]
        var paths = Set<Node>()
        var lowestScoreByState: [State: Int] = [startState: startNode.score]
        var lowestScore: Int = .max
        
        while let current = heap.popMin() {
            if current.state.point == end {
                lowestScore = min(lowestScore, current.score)
                
                if current.score <= lowestScore {
                    paths.insert(current)
                }
                
                continue
            }
            
            var nextAvailableNodes = [Node]()
            
            let forwardState = current.state.forward()
            if grid.isPointInside(forwardState.point),
               grid[forwardState.point] != .wall,
               !current.visited.contains(forwardState) {
                let next = Node(
                    state: forwardState,
                    visited: current.visited.union([forwardState]),
                    score: current.score + 1
                )
                
                nextAvailableNodes.append(next)
            }
            
            let leftState = current.state.turningLeft()
            if !current.visited.contains(leftState) {
                let wouldHaveTurnedLeftTwice = current.visited.contains(leftState.turningRight()) &&
                    current.visited.contains(leftState.turningRight().turningRight())
                
                if !wouldHaveTurnedLeftTwice {
                    let next = Node(
                        state: leftState,
                        visited: current.visited.union([leftState]),
                        score: current.score + 1_000
                    )
                    nextAvailableNodes.append(next)
                }
            }
            
            let rightState = current.state.turningRight()
            if !current.visited.contains(rightState) {
                let wouldHaveTurnedRightTwice = current.visited.contains(rightState.turningLeft()) &&
                    current.visited.contains(rightState.turningLeft().turningLeft())
                
                if !wouldHaveTurnedRightTwice {
                    let next = Node(
                        state: rightState,
                        visited: current.visited.union([rightState]),
                        score: current.score + 1_000
                    )
                    nextAvailableNodes.append(next)
                }
            }
            
            for nextAvailableNode in nextAvailableNodes {
                let canEnqueue = if let score = lowestScoreByState[nextAvailableNode.state] {
                    score >= nextAvailableNode.score && nextAvailableNode.score <= lowestScore
                }
                else {
                    true
                }
                
                if canEnqueue {
                    let lowestScoreForState = if let existingScore = lowestScoreByState[nextAvailableNode.state] {
                        min(existingScore, nextAvailableNode.score)
                    }
                    else {
                        nextAvailableNode.score
                    }
                    
                    lowestScoreByState[nextAvailableNode.state] = lowestScoreForState
                    heap.insert(nextAvailableNode)
                }
            }
        }
        
        return (lowestScore, paths)
    }
}

private struct Node: Hashable, Comparable {
    let state: State
    let visited: Set<State>
    let score: Int
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.score < rhs.score
    }
}

private struct State: Hashable {
    let point: Point2D
    let direction: Direction
    
    func forward() -> State {
        State(
            point: point.applying(direction.translation),
            direction: direction
        )
    }
    
    func turningLeft() -> State {
        State(
            point: point,
            direction: direction.turningLeft()
        )
    }
    
    func turningRight() -> State {
        State(
            point: point,
            direction: direction.turningRight()
        )
    }
}

private enum Tile: Character {
    case start = "S"
    case end = "E"
    case wall = "#"
}

private enum Direction {
    case up
    case right
    case down
    case left
    
    var translation: Translation2D {
        switch self {
        case .up:
            .up
        case .right:
            .right
        case .down:
            .down
        case .left:
            .left
        }
    }
    
    func turningLeft() -> Self {
        switch self {
        case .up:
            .left
        case .right:
            .up
        case .down:
            .right
        case .left:
            .down
        }
    }
    
    func turningRight() -> Self {
        switch self {
        case .up:
            .right
        case .right:
            .down
        case .down:
            .left
        case .left:
            .up
        }
    }
}
