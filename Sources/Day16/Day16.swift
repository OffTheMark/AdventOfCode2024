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
    }
    
    private func part1(_ grid: Grid2D<Tile>) -> Int {
        let pointOfStart = grid.points.first(where: { grid[$0] == .start })!
        let pointOfEnd = grid.points.first(where: { grid[$0] == .end })!
        let startState = State(point: pointOfStart, direction: .right)
        let startNode = Node(
            state: startState,
            visited: [startState],
            score: 0
        )
        
        var heap: Heap<Node> = [startNode]
        var lowestScoreByState: [State: Int] = [startState: startNode.score]
        
        while let current = heap.popMin() {
            if current.state.point == pointOfEnd {
                return current.score
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
