//
//  Day23.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-23.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import RegexBuilder

struct Day23: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day23",
            abstract: "Solve day 23 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let connections = try readLines().compactMap(Connection.init)
        
        let clock = ContinuousClock()
        printTitle("Part 1", level: .title1)
        let (part1Duration, numberOfSetsOfInterconnectedComputersStartingWithT) = clock.measure {
            part1(connections)
        }
        print(
            "Number of sets of interconnected computers starting with t:",
            numberOfSetsOfInterconnectedComputersStartingWithT
        )
        print("Elapsed time:", part1Duration, terminator: "\n\n")
    }
    
    private func part1(_ connections: [Connection]) -> Int {
        var connectedComputersByComputer = [String: Set<String>]()
        
        for connection in connections {
            connectedComputersByComputer[connection.first, default: []].insert(connection.second)
            connectedComputersByComputer[connection.second, default: []].insert(connection.first)
        }
        
        var setsOfInterconnectedComputers = Set<Set<String>>()
        
        for (computer, connectedComputers) in connectedComputersByComputer {
            for combination in connectedComputers.combinations(ofCount: 2) {
                let firstIsConnectedToOthers = connectedComputersByComputer[combination[0], default: []]
                    .isSuperset(of: [computer, combination[1]])
                let secondIsConnectedToOthers = connectedComputersByComputer[combination[1], default: []]
                    .isSuperset(of: [computer, combination[0]])
                
                guard firstIsConnectedToOthers, secondIsConnectedToOthers else {
                    continue
                }
                
                let interconnectedComputers: Set = [computer, combination[0], combination[1]]
                setsOfInterconnectedComputers.insert(interconnectedComputers)
            }
        }
        
        return setsOfInterconnectedComputers.count(where: { interconnectedComputers in
            interconnectedComputers.contains(where: { computer in
                computer.starts(with: "t")
            })
        })
    }
}

private struct Connection {
    let first: String
    let second: String
}

extension Connection {
    init?(rawValue: String) {
        let regex = Regex {
            let computerName = TryCapture {
                Repeat(count: 2) {
                    One("a" ... "z")
                }
            } transform: {
                String($0)
            }
            
            computerName
            "-"
            computerName
        }
        
        guard let match = rawValue.firstMatch(of: regex) else {
            return nil
        }
        
        self.first = match.output.1
        self.second = match.output.2
    }
}
