//
//  Day6.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-06.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import RegexBuilder

struct Day6: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day6",
            abstract: "Solve day 6 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let (grid, initialState) = try parseGrid(input: try readFile())
        
        printTitle("Part 1", level: .title1)
        let distinctPointsVisited = part1(grid: grid, initialState: initialState)
        print(
            "Distinct positions visited by the guard before leaving the mapped area:",
            distinctPointsVisited.count,
            terminator: "\n\n"
        )
        
        printTitle("Part 2", level: .title1)
        let pointsCausingLoops = part2(grid: grid, initialState: initialState, visitedPoints: distinctPointsVisited)
        print("Different positions causing a loop:", pointsCausingLoops)
    }
    
    private func parseGrid(input: String) throws -> (grid: Grid2D<Tile>, initialState: State) {
        var grid = Grid2D<Tile>(rawValue: input)
        var initialDirection: Direction!
        let initialPoint: Point2D! = grid.first(where: { _, tile in
            switch tile {
            case .guard(let direction):
                initialDirection = direction
                return true
                
            default:
                return false
            }
        })!.key
        grid[initialPoint] = nil
        
        return (grid, State(point: initialPoint, direction: initialDirection))
    }
    
    private func part1(grid: Grid2D<Tile>, initialState: State) -> Set<Point2D> {
        var currentState: State = initialState
        var visitedPoints = Set<Point2D>()
        
        repeat {
            visitedPoints.insert(currentState.point)
            
            let nextPoint = currentState.point.applying(currentState.direction.translation)
            
            if grid[nextPoint] == .obstacle {
                currentState.direction = currentState.direction.turningRight()
                continue
            }
            
            currentState.point = nextPoint
        } while grid.isPointInside(currentState.point)
        
        return visitedPoints
    }
    
    private func part2(grid: Grid2D<Tile>, initialState: State, visitedPoints: Set<Point2D>) -> Int {
        var candidates = visitedPoints
        candidates.remove(initialState.point)
        
        func causesLoop(point: Point2D) -> Bool {
            var grid = grid
            grid[point] = .obstacle
            var currentState = initialState
            var visitedStates = Set<State>()
            
            repeat {
                if visitedStates.contains(currentState) {
                    return true
                }
                
                visitedStates.insert(currentState)
                
                let nextPoint = currentState.point.applying(currentState.direction.translation)
                
                if grid[nextPoint] == .obstacle {
                    currentState.direction = currentState.direction.turningRight()
                    continue
                }
                
                currentState.point = nextPoint
            } while grid.isPointInside(currentState.point)
            
            return false
        }
        
        return candidates.count(where: causesLoop)
    }
}

private struct State: Hashable {
    var point: Point2D
    var direction: Direction
}

private enum Direction: Character {
    case up = "^"
    case right = ">"
    case down = "v"
    case left = "<"
    
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
    
    var translation: Translation2D {
        switch self {
        case .up:
            .up
        case .right:
            .right
        case .left:
            .left
        case .down:
            .down
        }
    }
}

private enum Tile: Equatable {
    case obstacle
    case `guard`(direction: Direction)
}

extension Tile: RawRepresentable {
    init?(rawValue: Character) {
        switch rawValue {
        case "#":
            self = .obstacle
        default:
            guard let direction = Direction(rawValue: rawValue) else {
                return nil
            }
            
            self = .guard(direction: direction)
        }
    }
    
    var rawValue: Character {
        switch self {
        case .obstacle:
            "#"
        case .guard(let direction):
            direction.rawValue
        }
    }
}
