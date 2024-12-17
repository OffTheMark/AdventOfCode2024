//
//  Day13.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-16.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections
import RegexBuilder

struct Day13: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day13",
            abstract: "Solve day 13 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let machines = try readFile().components(separatedBy: "\n\n").compactMap(Machine.init)
        
        let clock = ContinuousClock()
        printTitle("Part1", level: .title1)
        let (part1Duration, fewestTokensToWin) = clock.measure {
            part1(machines)
        }
        print("Fewest tokens to win all possible prizes:", fewestTokensToWin)
        print("Elapsed time:", part1Duration, terminator: "\n\n")
        
        printTitle("Part2", level: .title1)
        let (part2Duration, fewestTokensToWinAfterCorrectingPrizes) = clock.measure {
            part2(machines)
        }
        print("Fewest tokens to win all possible prizes:", fewestTokensToWinAfterCorrectingPrizes)
        print("Elapsed time:", part2Duration, terminator: "\n\n")
    }
    
    private func part1(_ machines: [Machine]) -> Int {
        machines.reduce(into: 0) { sum, machine in
            if let fewestTokensToWin = machine.fewestTokensToWin() {
                sum += fewestTokensToWin
            }
        }
    }
    
    private func part2(_ machines: [Machine]) -> Int {
        machines.reduce(into: 0) { sum, machine in
            if let fewestTokensToWin = machine.fewestTokensToWin(offsettingPrizeBy: 10_000_000_000_000) {
                sum += fewestTokensToWin
            }
        }
    }
}

private struct Machine {
    let buttonA: Translation2D
    let buttonB: Translation2D
    let prize: Point2D
    
    func fewestTokensToWin(offsettingPrizeBy offset: Int = 0) -> Int? {
        // Calculate if prizes are possible using Cramer's Rule
        // https://www.reddit.com/r/adventofcode/comments/1hd7irq/2024_day_13_an_explanation_of_the_mathematics/
        let prize = Point2D(x: prize.x + offset, y: prize.y + offset)
        let determinant = buttonA.deltaX * buttonB.deltaY - buttonA.deltaY * buttonB.deltaX
        let a = (prize.x * buttonB.deltaY - prize.y * buttonB.deltaX) / determinant
        let b = (buttonA.deltaX * prize.y - buttonA.deltaY * prize.x) / determinant
        
        guard buttonA.deltaX * a + buttonB.deltaX * b == prize.x,
              buttonA.deltaY * a + buttonB.deltaY * b == prize.y else {
            return nil
        }
        
        return 3 * a + b
    }
}

extension Machine {
    init?(rawValue: String) {
        let regex = Regex {
            let number = TryCapture {
                OneOrMore(.digit)
            } transform: {
                Int(String($0))
            }
            let deltaX = Regex {
                "X+"
                number
            }
            let deltaY = Regex {
                "Y+"
                number
            }
            
            "Button A: "
            deltaX
            ", "
            deltaY
            "\n"
            "Button B: "
            deltaX
            ", "
            deltaY
            "\n"
            "Prize: X="
            number
            ", "
            "Y="
            number
        }
        
        guard let match = rawValue.firstMatch(of: regex) else {
            return nil
        }
        
        self.buttonA = Translation2D(deltaX: match.output.1, deltaY: match.output.2)
        self.buttonB = Translation2D(deltaX: match.output.3, deltaY: match.output.4)
        self.prize = Point2D(x: match.output.5, y: match.output.6)
    }
}
