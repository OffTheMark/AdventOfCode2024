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
        
        let clock = ContinuousClock()
        printTitle("Part 1", level: .title1)
        let (part1Duration, lowestScore) = clock.measure {
            part1(grid)
        }
        print("Lowest score:", lowestScore)
        print("Elapsed time:", part1Duration, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let (part2Duration, bestSeatCount) = clock.measure {
            part2(grid: grid, lowestScore: lowestScore)
        }
        print("Lowest score:", bestSeatCount)
        print("Elapsed time:", part2Duration)
    }
    
    private func part1(_ grid: Grid2D<Tile>) -> Int {
        let start = grid.points.first(where: { grid[$0] == .start })!
        let end = grid.points.first(where: { grid[$0] == .end })!
        return shortestPath(from: start, to: end, in: grid).score
    }
    
    private func part2(grid: Grid2D<Tile>, lowestScore: Int) -> Int {
        let start = grid.points.first(where: { grid[$0] == .start })!
        let end = grid.points.first(where: { grid[$0] == .end })!
        let paths = paths(from: start, to: end, scoring: lowestScore, in: grid)
        let bestSeats = paths.reduce(into: Set<Point2D>()) { result, path in
            result.formUnion(path.visited.map(\.point))
        }
        return bestSeats.count
    }
    
    private func shortestPath(from start: Point2D, to end: Point2D, in grid: Grid2D<Tile>) -> Node {
        let startState = State(point: start, direction: .right)
        let startNode = Node(
            state: startState,
            visited: [startState],
            score: 0
        )
        
        var heap: Heap<Node> = [startNode]
        var lowestScoreByState: [State: Int] = [startState: startNode.score]
        
        while let current = heap.popMin() {
            if current.state.point == end {
                return current
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
                let next = Node(
                    state: leftState,
                    visited: current.visited.union([leftState]),
                    score: current.score + 1_000
                )
                nextAvailableNodes.append(next)
            }
            
            let rightState = current.state.turningRight()
            if !current.visited.contains(rightState) {
                let next = Node(
                    state: rightState,
                    visited: current.visited.union([rightState]),
                    score: current.score + 1_000
                )
                nextAvailableNodes.append(next)
            }
            
            for nextAvailableNode in nextAvailableNodes {
                let canEnqueue = if let score = lowestScoreByState[nextAvailableNode.state] {
                    score > nextAvailableNode.score
                }
                else {
                    true
                }
                
                if canEnqueue {
                    lowestScoreByState[nextAvailableNode.state] = nextAvailableNode.score
                    heap.insert(nextAvailableNode)
                }
            }
        }
        
        fatalError("Could not find shortest path")
    }
    
    private func paths(
        from start: Point2D,
        to end: Point2D,
        scoring targetScore: Int,
        in grid: Grid2D<Tile>
    ) -> Set<Node> {
        let startState = State(point: start, direction: .right)
        let startNode = Node(
            state: startState,
            visited: [startState],
            score: 0
        )
        
        var heap: Heap<Node> = [startNode]
        var paths = Set<Node>()
        var lowestScoreByState: [State: Int] = [startState: startNode.score]
        
        while let current = heap.popMin() {
            if current.state.point == end {
                if current.score == targetScore {
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
                    score >= nextAvailableNode.score && nextAvailableNode.score <= targetScore
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
        
        return paths
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
