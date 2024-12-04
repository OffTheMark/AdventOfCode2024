// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser

@main
struct AdventOfCode2024: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "aoc2024",
            abstract: "A program to solve Advent of Code 2024 puzzles",
            version: "0.0.1",
            subcommands: [
                Day1.self,
                Day2.self,
                Day3.self,
                Day4.self,
            ]
        )
    }
}
