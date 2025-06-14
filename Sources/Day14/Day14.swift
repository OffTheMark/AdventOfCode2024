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
    
    @Argument(
        help: "Puzzle input path",
        transform: { URL(filePath: $0, relativeTo: nil) }
    )
    var puzzleInputURL: URL
    
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
        
        printTitle("Part 2", level: .title1)
        let part2Duration = clock.measure {
            part2(robots: robots, frame: frame)
        }
        print("Elapsed time:", part2Duration)
    }
    
    private func part1(robots: [Robot], frame: Frame2D) -> Int {
        var currentRobots = robots
        
        for _ in 0 ..< 100 {
            currentRobots = nextStep(currentRobots, in: frame)
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
    
    private func part2(robots: [Robot], frame: Frame2D) {
        var robots = robots
        for secondsElapsed in 1... {
            robots = nextStep(robots, in: frame)
            
            let pointsOfRobots = robots.reduce(into: Set<Point2D>()) { points, robot in
                points.insert(robot.position)
            }
            
            let output = output(pointsOfRobots: pointsOfRobots, in: frame)
            
            if pointsOfRobots.count == robots.count {
                print("Number of seconds:", secondsElapsed)
                print(output)
                print(String(repeating: "=", count: frame.size.width))
                break
            }
        }
    }
    
    private func output(pointsOfRobots: Set<Point2D>, in frame: Frame2D) -> String {
        frame.rows
            .map { y in
                let line = String(
                    frame.columns.map({ x -> Character in
                        let point = Point2D(x: x, y: y)
                        return if pointsOfRobots.contains(point) {
                            "#"
                        }
                        else {
                            " "
                        }
                    })
                )
                return line
            }
            .joined(separator: "\n")
    }
    
    private func nextStep(_ robots: [Robot], in frame: Frame2D) -> [Robot] {
        robots.map { robot in
            var robot = robot
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
            robot.position = nextPosition
            return robot
        }
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
