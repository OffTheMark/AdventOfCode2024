//
//  Day4.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-04.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

struct Day4: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day4",
            abstract: "Solve day 4 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let allowedCharacters = Set("XMAS")
        let grid = Grid2D<Character>(rawValue: try readFile()) { character in
            guard allowedCharacters.contains(character) else {
                return nil
            }
            
            return character
        }
        
        printTitle("Part 1", level: .title1)
        let countOfWord = part1(grid)
        print("How many times does XMAS appear?", countOfWord, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let countOfXMASes = part2(grid)
        print("How many times does an X-MAS appear?", countOfXMASes)
    }
    
    func part1(_ grid: Grid2D<Character>) -> Int {
        let pointsOfLetterX: Set<Point2D> = grid.reduce(into: []) { result, pair in
            let (point, letter) = pair
            if letter == "X" {
                result.insert(point)
            }
        }
        let restOfXMAS = "MAS"
        let remainingLettersByOffset: [Int: Character] = restOfXMAS.indexed().reduce(into: [:]) { result, pair in
            let (index, character) = pair
            let offset = restOfXMAS.distance(from: restOfXMAS.startIndex, to: index) + 1
            result[offset] = character
        }
        let allowedDirections: [Translation2D] = [.up, .upRight, .right, .downRight, .down, .downLeft, .left, .upLeft]
        
        func hasXMASStarting(at point: Point2D, in direction: Translation2D) -> Bool {
            remainingLettersByOffset.allSatisfy { offset, letter in
                let pointOfLetter = point.applying(direction * offset)
                return grid[pointOfLetter] == letter
            }
        }
        
        let xmasCount = pointsOfLetterX.reduce(into: 0) { result, point in
            let countForPoint = allowedDirections.count(where: { direction in
                hasXMASStarting(at: point, in: direction)
            })
            result += countForPoint
        }
        return xmasCount
    }
    
    func part2(_ grid: Grid2D<Character>) -> Int {
        let pointsOfLetterA: Set<Point2D> = grid.reduce(into: []) { result, pair in
            let (point, letter) = pair
            if letter == "A" {
                result.insert(point)
            }
        }
        
        func hasXMASCentered(at point: Point2D) -> Bool {
            [Translation2D.upLeft, .upRight].allSatisfy({ translation in
                let top = point.applying(translation)
                let bottom = point.applying(-translation)
                var remainingLetters = Set("MS")
                
                guard let topLetter = grid[top], let bottomLetter = grid[bottom] else {
                    return false
                }
                
                guard remainingLetters.contains(topLetter) else {
                    return false
                }
                
                remainingLetters.remove(topLetter)
                
                return remainingLetters.contains(bottomLetter)
            })
        }
        
        return pointsOfLetterA.count(where: hasXMASCentered)
    }
}
