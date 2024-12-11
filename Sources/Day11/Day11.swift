//
//  Day11.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-11.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections

struct Day11: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day11",
            abstract: "Solve day 11 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let initialCountByStones: [Int: Int] = try readFile()
            .components(separatedBy: " ")
            .reduce(into: [:]) { result, part in
                guard let stone = Int(part) else {
                    return
                }
                
                result[stone, default: 0] += 1
            }
        
        let clock = ContinuousClock()
        printTitle("Part 1", level: .title1)
        let (part1Duration, countsByStoneAfter25Blinks) = clock.measure {
            blinkStones(initialCountByStones, numberOfTimes: 25)
        }
        print("Number of stones after 25 blinks:", countsByStoneAfter25Blinks.values.reduce(0, +))
        print("Elapsed time:", part1Duration, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let (part2Duration, countsByStoneAfter75Blinks) = clock.measure {
            blinkStones(countsByStoneAfter25Blinks, numberOfTimes: 50)
        }
        print("Number of stones after 75 blinks:", countsByStoneAfter75Blinks.values.reduce(0, +))
        print("Elapsed time:", part2Duration, terminator: "\n\n")
    }
    
    private func blinkStones(_ countsByStone: [Int: Int], numberOfTimes: Int) -> [Int: Int] {
        var currentCountsByStone = countsByStone
        
        for _ in 0 ..< numberOfTimes {
            var nextCountsByStone = [Int: Int]()
            
            stoneLoop: for (stone, count) in currentCountsByStone {
                if stone == 0 {
                    nextCountsByStone[1, default: 0] += count
                    continue stoneLoop
                }
                
                let digits = stone.digits
                let numberOfDigits = digits.count
                
                if numberOfDigits.isMultiple(of: 2) {
                    let middleIndex = numberOfDigits / 2
                    
                    let leftDigits = digits[..<middleIndex]
                    let leftStone = leftDigits.enumerated().reduce(into: 0) { result, element in
                        let (index, digit) = element
                        result += digit * Int(pow(10, Double(middleIndex - index - 1)))
                    }
                    
                    let rightDigits = digits[middleIndex...]
                    let rightStone = rightDigits.enumerated().reduce(into: 0) { result, element in
                        let (index, digit) = element
                        result += digit * Int(pow(10, Double(middleIndex - index - 1)))
                    }
                    
                    nextCountsByStone[leftStone, default: 0] += count
                    nextCountsByStone[rightStone, default: 0] += count
                    continue stoneLoop
                }
                
                nextCountsByStone[stone * 2024, default: 0] += count
            }
            
            currentCountsByStone = nextCountsByStone
        }
        
        return currentCountsByStone
    }
}

extension Int {
    var digits: [Int] {
        var current = abs(self)
        var reversedDigits = [current % 10]
        
        while current >= 10 {
            current /= 10
            let digit = current % 10
            reversedDigits.append(digit)
        }
        
        return reversedDigits.reversed()
    }
}
