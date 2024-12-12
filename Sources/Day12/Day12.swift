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
        printTitle("Part 1", level: .title1)
        let (part1Duration, totalPriceOfFencing) = clock.measure {
            part1(grid)
        }
        print("Total price of fencing all regions on the map:", totalPriceOfFencing)
        print("Elapsed time:", part1Duration, terminator: "\n\n")
    }
    
    func part1(_ grid: Grid2D<Character>) -> Int {
        let gardenPlotsByPlant = gardenPlotsByPlant(in: grid)
        
        return gardenPlotsByPlant.values.lazy
            .flatMap({ $0 })
            .reduce(into: 0) { totalPrice, plot in
                totalPrice += plot.area() * plot.perimeter()
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
}
