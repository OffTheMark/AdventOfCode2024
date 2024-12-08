//
//  Day8.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-04.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Algorithms

struct Day8: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day8",
            abstract: "Solve day 8 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let allowedCharacters: CharacterSet = .lowercaseLetters
            .union(.uppercaseLetters)
            .union(CharacterSet(charactersIn: "0123456789"))
        let grid = Grid2D<Character>(rawValue: try readFile()) { character in
            guard allowedCharacters.containsUnicodeScalars(of: character) else {
                return nil
            }
            
            return character
        }
        
        printTitle("Part 1", level: .title1)
        let uniqueAntinodeLocations = part1(grid)
        print(
            "Unique locations within the map containing an antinode:",
            uniqueAntinodeLocations.count,
            terminator: "\n\n"
        )
        
        printTitle("Part 2", level: .title1)
        let uniqueAntinodeLocationsUsingUpdatedModel = part2(grid)
        print(
            "Unique locations within the map containing an antinode using the updated model:",
            uniqueAntinodeLocationsUsingUpdatedModel.count
        )
    }
    
    func part1(_ grid: Grid2D<Character>) -> Set<Point2D> {
        let pointsByFrequency: [Character: Set<Point2D>] = grid.reduce(into: [:], { result, pair in
            let (point, frequency) = pair
            result[frequency, default: []].insert(point)
        })
        
        return pointsByFrequency.values.reduce(into: Set<Point2D>()) { locations, points in
            let antinodesForFrequency: Set<Point2D> = points.combinations(ofCount: 2)
                .reduce(into: []) { antinodes, combination in
                    let translation = combination[0].translation(to: combination[1])
                    let antinodesOfCombination = [
                        combination[1].applying(translation),
                        combination[0].applying(-translation)
                    ]
                    .filter({ candidate in
                        grid.isPointInside(candidate)
                    })
                    
                    antinodes.formUnion(antinodesOfCombination)
                }
            locations.formUnion(antinodesForFrequency)
        }
    }
    
    func part2(_ grid: Grid2D<Character>) -> Set<Point2D> {
        let pointsByFrequency: [Character: Set<Point2D>] = grid.reduce(into: [:], { result, pair in
            let (point, frequency) = pair
            result[frequency, default: []].insert(point)
        })
        
        return pointsByFrequency.values.reduce(into: Set<Point2D>()) { locations, points in
            let antinodesForFrequency: Set<Point2D> = points.combinations(ofCount: 2)
                .reduce(into: []) { antinodes, combination in
                    let translation = combination[0].translation(to: combination[1])
                    let normalizedTranslation = translation.normalized
                    
                    var current = combination[0]
                    while grid.isPointInside(current) {
                        antinodes.insert(current)
                        
                        current.apply(-normalizedTranslation)
                    }
                    
                    current = combination[0]
                    while grid.isPointInside(current) {
                        antinodes.insert(current)
                        
                        current.apply(normalizedTranslation)
                    }
                }
            locations.formUnion(antinodesForFrequency)
        }
    }
}

extension CharacterSet {
    func containsUnicodeScalars(of character: Character) -> Bool {
        character.unicodeScalars.allSatisfy(contains)
    }
}

extension Int {
    func isDivisible(by other: Int) -> Bool {
        quotientAndRemainder(dividingBy: other).remainder == 0
    }
}
