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
        let targetWord = "XMAS"
        let lettersOfTargetByOffset: [Int: Character] = targetWord.indexed().reduce(into: [:]) { result, pair in
            let (index, character) = pair
            let offset = targetWord.distance(from: targetWord.startIndex, to: index)
            result[offset] = character
        }
        let directions: [Translation2D] = [.up, .upRight, .right, .downRight, .down, .downLeft, .left, .upLeft]
        let pointsOfLetterX: Set<Point2D> = grid.valuesByPosition.reduce(into: []) { result, pair in
            let (point, letter) = pair
            if letter == "X" {
                result.insert(point)
            }
        }
        
        let count = pointsOfLetterX.reduce(into: 0) { result, point in
            let countForPoint = directions.count(where: { translation in
                lettersOfTargetByOffset.allSatisfy { offset, letter in
                    let pointOfLetter = point.applying(translation * offset)
                    return grid.valuesByPosition[pointOfLetter] == letter
                }
            })
            result += countForPoint
        }
        return count
    }
    
    func part2(_ grid: Grid2D<Character>) -> Int {
        let pointsOfLetterA: Set<Point2D> = grid.valuesByPosition.reduce(into: []) { result, pair in
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
                
                guard let topLetter = grid.valuesByPosition[top],
                      let bottomLetter = grid.valuesByPosition[bottom] else {
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
