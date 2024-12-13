//
//  Day12.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-11.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections
import Algorithms

struct Day12: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day12",
            abstract: "Solve day 12 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let grid = Grid2D<Character>(rawValue: try readFile()) { $0 }
        
        let clock = ContinuousClock()
        
        printTitle("Mapping garden plots", level: .title1)
        let (mappingDuration, gardenPlots) = clock.measure {
            gardenPlotsByPlant(in: grid)
        }
        print("Elapsed time:", mappingDuration, terminator: "\n\n")
        
        printTitle("Part 1", level: .title1)
        let (part1Duration, totalPriceOfFencing) = clock.measure {
            part1(gardenPlots)
        }
        print("Total price of fencing all regions on the map:", totalPriceOfFencing)
        print("Elapsed time:", part1Duration, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let (part2Duration, newTotalPriceOfFencing) = clock.measure {
            part2(gardenPlotsByPlant: gardenPlots, grid: grid)
        }
        print("New total price of fencing all regions on the map:", newTotalPriceOfFencing)
        print("Elapsed time:", part2Duration, terminator: "\n\n")
    }
    
    private func part1(_ gardenPlotsByPlant: [Character: [GardenPlot]]) -> Int {
        let gardenPlots = gardenPlotsByPlant.values.lazy.flatMap({ $0 })
        
        return gardenPlots.reduce(into: 0) { totalPrice, plot in
            totalPrice += plot.area() * plot.perimeter()
        }
    }
    
    private func part2(gardenPlotsByPlant: [Character: [GardenPlot]], grid: Grid2D<Character>) -> Int {
        let gardenPlots = gardenPlotsByPlant.values.lazy.flatMap({ $0 })
        
        return gardenPlots.reduce(into: 0) { totalPrice, gardenPlot in
            let cornerCount = gardenPlot.cornerCount()
            let area = gardenPlot.area()
            printGardenPlot(gardenPlot, in: grid)
            totalPrice += cornerCount * area
        }
    }
    
    private func printGardenPlot(_ gardenPlot: GardenPlot, in grid: Grid2D<Character>) {
        let minAndMaxX = gardenPlot.map(\.x).minAndMax()!
        let minAndMaxY = gardenPlot.map(\.y).minAndMax()!
        
        print("Plot:")
        
        for y in minAndMaxY.min ... minAndMaxY.max {
            let line = String(
                (minAndMaxX.min ... minAndMaxX.max).map { x in
                    let point = Point2D(x: x, y: y)
                    return if gardenPlot.contains(point) {
                        grid[point]!
                    }
                    else {
                        "."
                    }
                }
            )
            print(line)
        }
    }
    
    private func gardenPlotsByPlant(in grid: Grid2D<Character>) -> [Character: [GardenPlot]] {
        var visited = Set<Point2D>()
        var gardenPlotsByPlant = [Character: [GardenPlot]]()
        
        for (y, x) in product(grid.frame.rows, grid.frame.columns) {
            let point = Point2D(x: x, y: y)
            let plant = grid[point]!
            
            if visited.contains(point) {
                continue
            }
            
            let gardenPlot = gardenPlot(containing: point)
            gardenPlotsByPlant[plant, default: []].append(gardenPlot)
        }
        
        func gardenPlot(containing point: Point2D) -> GardenPlot {
            let allowedDirections: [Translation2D] = [
                .up,
                .right,
                .down,
                .left,
            ]
            let plant = grid[point]!
            
            var gardenPlot = GardenPlot()
            var stack: Deque<Point2D> = [point]
            
            while let currentPoint = stack.popLast() {
                gardenPlot.insert(currentPoint)
                visited.insert(currentPoint)
                
                for nextPoint in allowedDirections.map({ currentPoint.applying($0) }) {
                    if visited.contains(nextPoint) {
                        continue
                    }
                    
                    guard grid.isPointInside(nextPoint) else {
                        continue
                    }
                    
                    guard grid[nextPoint] == plant else {
                        continue
                    }
                    
                    stack.append(nextPoint)
                }
            }
            
            return gardenPlot
        }
        
        return gardenPlotsByPlant
    }
}

private typealias GardenPlot = Set<Point2D>

extension GardenPlot {
    func area() -> Int {
        count
    }
    
    func perimeter() -> Int {
        let edges: [Translation2D] = [.up, .right, .down, .left]
        
        let perimeter = reduce(into: 0) { perimeter, point in
            let sidesNotTouchingOthers = edges.count(where: { translation in
                let neighbor = point.applying(translation)
                return !contains(neighbor)
            })
            perimeter += sidesNotTouchingOthers
        }
        return perimeter
    }
    
    func perimeterPoints() -> Set<Point2D> {
        let edges: [Translation2D] = [.up, .right, .down, .left]
        let perimeterPoints = Set(
            filter({ point in
                edges.contains(where: { translation in
                    let neighbor = point.applying(translation)
                    return !contains(neighbor)
                })
            })
        )
        return perimeterPoints
    }
    
    func cornerCount() -> Int {
        let perimeterPoints = perimeterPoints()
        
        let corners: Set<Corner> = perimeterPoints.reduce(into: []) { corners, point in
            let up = point.applying(.up)
            let upRight = point.applying(.upRight)
            let right = point.applying(.right)
            let downRight = point.applying(.downRight)
            let down = point.applying(.down)
            let downLeft = point.applying(.downLeft)
            let left = point.applying(.left)
            let upLeft = point.applying(.upLeft)
            
            // Exterior corners
            if isDisjoint(with: [left, up]) {
                corners.insert(Corner(point: point, direction: .upLeft))
            }
            if isDisjoint(with: [up, right]) {
                corners.insert(Corner(point: point, direction: .upRight))
            }
            if isDisjoint(with: [right, down]) {
                corners.insert(Corner(point: point, direction: .downRight))
            }
            if isDisjoint(with: [down, left]) {
                corners.insert(Corner(point: point, direction: .downLeft))
            }
            
            // Interior corners
            if contains(upLeft), !contains(up) {
                corners.insert(Corner(point: left, direction: .upRight))
            }
            if contains(upLeft), !contains(left) {
                corners.insert(Corner(point: up, direction: .downLeft))
            }
            if contains(upRight), !contains(up) {
                corners.insert(Corner(point: right, direction: .upLeft))
            }
            if contains(upRight), !contains(right) {
                corners.insert(Corner(point: up, direction: .downRight))
            }
            
            if contains(downRight), !contains(down) {
                corners.insert(Corner(point: right, direction: .downLeft))
            }
            if contains(downRight), !contains(right) {
                corners.insert(Corner(point: down, direction: .upRight))
            }
            if contains(downLeft), !contains(down) {
                corners.insert(Corner(point: left, direction: .downRight))
            }
            if contains(downLeft), !contains(left) {
                corners.insert(Corner(point: down, direction: .upLeft))
            }
        }
        return corners.count
    }
}

private struct Corner: Hashable {
    let point: Point2D
    let direction: Translation2D
}
