//
//  Day15.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-14.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections
import RegexBuilder

struct Day15: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day15",
            abstract: "Solve day 15 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let (grid, moves) = try parse()
        
        let clock = ContinuousClock()
        printTitle("Part 1", level: .title1)
        let (part1Duration, sumOfGPSCoordinates) = clock.measure {
            part1(grid: grid, moves: moves)
        }
        print("Sum of boxes' GPS coordinates:", sumOfGPSCoordinates)
        print("Elapsed time:", part1Duration, terminator: "\n\n")
    }
    
    private func parse() throws -> (grid: Grid2D<Tile>, moves: [Move]) {
        let input = try readFile()
        let parts = input.components(separatedBy: "\n\n")
        let grid = Grid2D<Tile>(rawValue: parts[0])
        let moves = parts[1].compactMap(Move.init)
        
        return (grid, moves)
    }
    
    private func part1(grid: Grid2D<Tile>, moves: [Move]) -> Int {
        var pointOfRobot = grid.points.first(where: { point in
            grid[point] == .robot
        })!
        var grid = grid
        grid[pointOfRobot] = nil
        
        for move in moves {
            let translation = move.translation
            let nextPoint = pointOfRobot.applying(translation)
            
            guard grid.isPointInside(nextPoint) else {
                continue
            }
            
            if grid[nextPoint] == .wall {
                continue
            }
            
            if !grid.hasValue(at: nextPoint) {
                pointOfRobot = nextPoint
                continue
            }
            
            guard grid[nextPoint] == .box else {
                continue
            }
            
            var pointBehind = nextPoint.applying(translation)
            let boxesInLine = Array(
                sequence(first: nextPoint) { current in
                    let next = current.applying(translation)
                    if grid[next] == .box {
                        pointBehind = next.applying(translation)
                        return next
                    }
                    else {
                        return nil
                    }
                }
            )
            
            guard !grid.hasValue(at: pointBehind) else {
                continue
            }
            
            let firstBox = boxesInLine.first!
            grid.removeValue(forPoint: firstBox)
            grid[pointBehind] = .box
            pointOfRobot = nextPoint
        }
        
        return grid.reduce(into: 0) { sum, element in
            let (point, value) = element
            
            if value == .box {
                sum += point.x + 100 * point.y
            }
        }
    }
}

private enum Tile: Character {
    case wall = "#"
    case box = "O"
    case robot = "@"
}

private enum Move: Character {
    case up = "^"
    case right = ">"
    case down = "v"
    case left = "<"
    
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
}
