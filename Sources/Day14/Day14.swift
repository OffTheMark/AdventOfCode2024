//
//  Day14.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-14.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections
import RegexBuilder

struct Day14: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day14",
            abstract: "Solve day 14 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let robots = try readLines().compactMap(Robot.init)
        let frame = Frame2D(origin: .zero, size: Size2D(width: 101, height: 103))
        
        let clock = ContinuousClock()
        printTitle("Part 1", level: .title1)
        let (part1Duration, safetyFactorAfter100Seconds) = clock.measure {
            part1(robots: robots, frame: frame)
        }
        print("Safety factory after 100 seconds:", safetyFactorAfter100Seconds)
        print("Elapsed time:", part1Duration, terminator: "\n\n")
    }
    
    private func part1(robots: [Robot], frame: Frame2D) -> Int {
        var currentRobots = robots
        
        for _ in 0 ..< 100 {
            let nextRobots = currentRobots.reduce(into: [Robot](), { result, robot in
                var nextPosition = robot.position.applying(robot.velocity)
                
                if nextPosition.x < frame.minX {
                    nextPosition.x += frame.size.width
                }
                if nextPosition.x > frame.maxX {
                    nextPosition.x -= frame.size.width
                }
                if nextPosition.y < frame.minY {
                    nextPosition.y += frame.size.height
                }
                if nextPosition.y > frame.maxY {
                    nextPosition.y -= frame.size.height
                }
                
                var newRobot = robot
                newRobot.position = nextPosition
                result.append(newRobot)
            })
            currentRobots = nextRobots
        }
        
        let midX = frame.minX + frame.size.width / 2
        let midY = frame.minY + frame.size.height / 2
        let quadrants: [(x: ClosedRange<Int>, y: ClosedRange<Int>)] = [
            (frame.minX ... midX - 1, frame.minY ... midY - 1),
            (midX + 1 ... frame.maxX, frame.minY ... midY - 1),
            (frame.minX ... midX - 1, midY + 1 ... frame.maxY),
            (midX + 1 ... frame.maxX, midY + 1 ... frame.maxY),
        ]
        let safetyRating = quadrants.reduce(into: 1) { product, quadrant in
            product *= currentRobots.count(where: { robot in
                quadrant.x.contains(robot.position.x) && quadrant.y.contains(robot.position.y)
            })
        }
        return safetyRating
    }
}

private struct Robot: Hashable {
    let id = UUID()
    var position: Point2D
    let velocity: Translation2D
}

extension Robot {
    init?(rawValue: String) {
        let regex = Regex {
            let number = TryCapture {
                Optionally("-")
                OneOrMore(.digit)
            } transform: {
                Int(String($0))
            }
            
            "p="
            number
            ","
            number
            " "
            "v="
            number
            ","
            number
        }
        
        guard let match = rawValue.firstMatch(of: regex) else {
            return nil
        }
        
        self.position = Point2D(x: match.output.1, y: match.output.2)
        self.velocity = Translation2D(deltaX: match.output.3, deltaY: match.output.4)
        
    }
}
