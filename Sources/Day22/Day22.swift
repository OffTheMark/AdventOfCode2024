//
//  Day22.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-22.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections

struct Day22: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day22",
            abstract: "Solve day 22 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let secretNumbers = try readLines().compactMap(Int.init)
        
        let clock = ContinuousClock()
        printTitle("Generating secret numbers", level: .title1)
        let (generatingDuration, generatedSequences) = clock.measure {
            secretNumbers.map({ nthSecretNumbers(2_000, for: $0) })
        }
        print("Elapsed time:", generatingDuration, terminator: "\n\n")
        
        printTitle("Part 1", level: .title1)
        let sumOfTwoThousandthNumbers = generatedSequences.reduce(into: 0) { sum, sequence in
            sum += sequence.last!
        }
        print(
            "Sum of the 2000th secret numbers generated by each buyer:",
            sumOfTwoThousandthNumbers,
            terminator: "\n\n"
        )
        
        printTitle("Part 2", level: .title1)
        let (part2Duration, maximumBananas) = clock.measure {
            part2(generatedSequences)
        }
        print("Most bananas we can get:", maximumBananas)
        print("Elapsed time", part2Duration)
    }
    
    func nthSecretNumbers(_ lastIndex: Int, for initial: Int) -> [Int] {
        var result = [initial]
        var current = initial
        
        for _ in 0 ..< lastIndex {
            current = nextSecretNumber(current)
            result.append(current)
        }
        
        return result
    }
    
    func part2(_ generatedSequences: [[Int]]) -> Int {
        var maximum: Int = .min
        var totalBySequence = [[Int]: Int]()
        
        for sequence in generatedSequences {
            var distinctSequences = Set<[Int]>()
            
            for slice in sequence.windows(ofCount: 5) {
                let firstPrice = slice[slice.startIndex].unitDigit
                let secondPrice = slice[slice.index(slice.startIndex, offsetBy: 1)].unitDigit
                let thirdPrice = slice[slice.index(slice.startIndex, offsetBy: 2)].unitDigit
                let fourthPrice = slice[slice.index(slice.startIndex, offsetBy: 3)].unitDigit
                let fifthPrice = slice[slice.index(slice.startIndex, offsetBy: 4)].unitDigit
                
                let differenceSequence = [
                    secondPrice - firstPrice,
                    thirdPrice - secondPrice,
                    fourthPrice - thirdPrice,
                    fifthPrice - fourthPrice,
                ]
                if !distinctSequences.contains(differenceSequence) {
                    distinctSequences.insert(differenceSequence)
                    totalBySequence[differenceSequence, default: 0] += fifthPrice
                    maximum = max(maximum, totalBySequence[differenceSequence, default: 0])
                }
            }
        }
        
        return maximum
    }
    
    private func nthSecretNumber(_ index: Int, for initial: Int) -> Int {
        var current = initial
        for _ in 0 ..< index {
            let next = nextSecretNumber(current)
            current = next
        }
        
        return current
    }
    
    private func nextSecretNumber(_ secretNumber: Int) -> Int {
        var secretNumber = secretNumber
        
        func mixValue(_ value: Int) -> Int {
            value ^ secretNumber
        }
        
        func prune(_ value: inout Int) {
            value %= 16_777_216
        }
        
        secretNumber = mixValue(secretNumber * 64)
        prune(&secretNumber)
        
        secretNumber = mixValue(secretNumber / 32)
        prune(&secretNumber)
        
        secretNumber = mixValue(secretNumber * 2_048)
        prune(&secretNumber)
        
        return secretNumber
    }
}

extension Int {
    var unitDigit: Int {
        self % 10
    }
}
