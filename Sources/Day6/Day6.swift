//
//  Day6.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-04.
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
        let grid = Grid2D<Tile>(rawValue: try readFile())
        
        printTitle("Part 1", level: .title1)
        let distinctPointsVisited = part1(grid: grid)
        print("Distinct positions visited by the guard before leaving the mapped area:", distinctPointsVisited, terminator: "\n\n")
    }
    
    private func part1(grid: Grid2D<Tile>) -> Int {
        var grid = grid
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
        
        var currentDirection: Direction = initialDirection
        var currentPoint: Point2D = initialPoint
        
        var visitedPoints = Set<Point2D>()
        
        repeat {
            visitedPoints.insert(currentPoint)
            
            let nextPoint = currentPoint.applying(currentDirection.translation)
            
            if grid[nextPoint] == .obstacle {
                currentDirection = currentDirection.turningRight()
                continue
            }
            
            currentPoint = nextPoint
        } while grid.isPointInside(currentPoint)
        
        return visitedPoints.count
    }
}

private struct State: Hashable {
    let point: Point2D
    let direction: Direction
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
