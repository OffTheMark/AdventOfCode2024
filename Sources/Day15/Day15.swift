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
    
    @Argument(
        help: "Puzzle input path",
        transform: { URL(filePath: $0, relativeTo: nil) }
    )
    var puzzleInputURL: URL
    
    func run() throws {
        let (grid, moves) = try parse()
        
        let clock = ContinuousClock()
        printTitle("Part 1", level: .title1)
        let (part1Duration, sumOfGPSCoordinates) = clock.measure {
            part1(grid: grid, moves: moves)
        }
        print("Sum of boxes' GPS coordinates:", sumOfGPSCoordinates)
        print("Elapsed time:", part1Duration, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let (part2Duration, sumOfGPSCoordinatesAfterInflation) = clock.measure {
            part2(grid: grid, moves: moves)
        }
        print("Sum of boxes' GPS coordinates:", sumOfGPSCoordinatesAfterInflation)
        print("Elapsed time:", part2Duration)
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
    
    private func part2(grid: Grid2D<Tile>, moves: [Move]) -> Int {
        var grid = inflate(grid)
        var pointOfRobot = grid.points.first(where: { point in
            grid[point] == .robot
        })!
        
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
                grid.removeValue(forPoint: pointOfRobot)
                pointOfRobot = nextPoint
                grid[pointOfRobot] = .robot
                continue
            }
            
            let boxParts: Set<InflatedTile> = [.leftBox, .rightBox]
            
            guard let nextValue = grid[nextPoint], boxParts.contains(nextValue) else {
                continue
            }
            
            var wouldHitWall = false
            
            func boxes(touching boxes: Set<Point2D>, movingWith translation: Translation2D) -> Set<Point2D> {
                var nextBoxes = Set<Point2D>()
                
                for point in boxes {
                    let nextPoint = point.applying(translation)
                    
                    guard let nextValue = grid[nextPoint] else {
                        continue
                    }
                    
                    switch (nextValue, translation) {
                    case (.leftBox, .up), (.leftBox, .down):
                        nextBoxes.insert(nextPoint)
                        nextBoxes.insert(Point2D(x: nextPoint.x + 1, y: nextPoint.y))
                        
                    case (.rightBox, .up), (.rightBox, .down):
                        nextBoxes.insert(nextPoint)
                        nextBoxes.insert(Point2D(x: nextPoint.x - 1, y: nextPoint.y))
                        
                    case (.leftBox, _), (.rightBox, _):
                        nextBoxes.insert(nextPoint)
                        
                    case (.wall, _):
                        wouldHitWall = true
                        return []
                        
                    default:
                        break
                    }
                }
                
                return nextBoxes
            }
            
            let firstBoxes = boxes(touching: [pointOfRobot], movingWith: translation)
            
            let boxesInLine: [Set<Point2D>] = Array(
                sequence(first: firstBoxes, next: { currentBoxes in
                    let nextBoxes = boxes(touching: currentBoxes, movingWith: translation)
                    
                    return if nextBoxes.isEmpty {
                        nil
                    }
                    else {
                        nextBoxes
                    }
                })
            )
            
            if wouldHitWall {
                continue
            }
            
            for boxes in boxesInLine.reversed() {
                for point in boxes {
                    let value = grid[point]!
                    grid.removeValue(forPoint: point)
                    grid[point.applying(translation)] = value
                }
            }
            
            grid.removeValue(forPoint: pointOfRobot)
            pointOfRobot.apply(translation)
            grid[pointOfRobot] = .robot
        }
        
        print(grid.debugOutput())
        
        return grid.reduce(into: 0) { sum, element in
            let (point, value) = element
            
            if value == .leftBox {
                sum += point.x + 100 * point.y
            }
        }
    }
    
    private func inflate(_ grid: Grid2D<Tile>) -> Grid2D<InflatedTile> {
        let inflatedSize = Size2D(
            width: grid.frame.size.width * 2,
            height: grid.frame.size.width
        )
        var inflatedGrid = Grid2D<InflatedTile>(frame: Frame2D(origin: grid.frame.origin, size: inflatedSize))
        
        for (point, value) in grid {
            let newPoint = Point2D(
                x: grid.frame.minX + (point.x - grid.frame.minX) * 2,
                y: point.y
            )
            let neighbor = Point2D(x: newPoint.x + 1, y: newPoint.y)
            
            switch value {
            case .wall:
                inflatedGrid[newPoint] = .wall
                inflatedGrid[neighbor] = .wall
            
            case .box:
                inflatedGrid[newPoint] = .leftBox
                inflatedGrid[neighbor] = .rightBox
                
            case .robot:
                inflatedGrid[newPoint] = .robot
            }
        }
        
        return inflatedGrid
    }
}

private enum Tile: Character {
    case wall = "#"
    case box = "O"
    case robot = "@"
}

private enum InflatedTile: Character {
    case wall = "#"
    case leftBox = "["
    case rightBox = "]"
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
