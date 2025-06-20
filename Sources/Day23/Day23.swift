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
    
    @Argument(
        help: "Puzzle input path",
        transform: { URL(filePath: $0, relativeTo: nil) }
    )
    var puzzleInputURL: URL
    
    func run() throws {
        let connections = try readLines().compactMap(Connection.init)
        
        let clock = ContinuousClock()
        printTitle("Calculating connected computers", level: .title1)
        let (connectedComputersDuration, connectedComputersByComputer) = clock.measure {
            self.connectedComputersByComputer(connections)
        }
        print("Elapsed time:", connectedComputersDuration, terminator: "\n\n")
        
        printTitle("Part 1", level: .title1)
        let (part1Duration, numberOfSetsOfInterconnectedComputersStartingWithT) = clock.measure {
            part1(connectedComputersByComputer)
        }
        print(
            "Number of sets of interconnected computers starting with t:",
            numberOfSetsOfInterconnectedComputersStartingWithT
        )
        print("Elapsed time:", part1Duration, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let (part2Duration, password) = clock.measure {
            part2(connectedComputersByComputer)
        }
        print("LAN party password:", password)
        print("Elapsed time:", part2Duration)
    }
    
    private func connectedComputersByComputer(_ connections: [Connection]) -> [String: Set<String>] {
        connections.reduce(into: [:]) { result, connection in
            result[connection.first, default: []].insert(connection.second)
            result[connection.second, default: []].insert(connection.first)
        }
    }
    
    private func part1(_ connectedComputersByComputer: [String: Set<String>]) -> Int {
        var setsOfInterconnectedComputers = Set<Set<String>>()
        
        for (computer, connectedComputers) in connectedComputersByComputer {
            for combination in connectedComputers.combinations(ofCount: 2) {
                let areInterconnected = combination.allSatisfy { current in
                    let others = Set([computer]).union(Set(combination).subtracting([current]))
                    return connectedComputersByComputer[current, default: []].isSuperset(of: others)
                }
                
                guard areInterconnected else {
                    continue
                }
                
                let interconnectedComputers = Set([computer] + combination)
                setsOfInterconnectedComputers.insert(interconnectedComputers)
            }
        }
        
        return setsOfInterconnectedComputers.count(where: { interconnectedComputers in
            interconnectedComputers.contains(where: { computer in
                computer.starts(with: "t")
            })
        })
    }
    
    private func part2(_ connectedComputersByComputer: [String: Set<String>]) -> String {
        var largestSet = Set<String>()
        
        // We sort computers by descending number of other connected computers. This allows us to stop iterating over
        // computers when it's impossible to find a bigger set.
        for (computer, connectedComputers) in connectedComputersByComputer
            .sorted(by: { $0.value.count > $1.value.count }) {
            // If the number of computers connected to the current computer is less than to the number of computers in
            // the largest set, we stop iterating: we can't find a larger set.
            if connectedComputers.count < largestSet.count {
                break
            }
            
            // We find combinations of decreasing count in the connected computers. The range of combination count where
            // we could find the largest set has:
            // - a lower bound equal to the maximum between 3 (as per part 1) and the size of the current largest set
            // - an upper bound that is equal to the maximum between 3 and the number of connected computers.
            let countRange = max(3, largestSet.count) ... max(3, connectedComputers.count)
            
            for count in countRange.reversed() {
                for combination in connectedComputers.combinations(ofCount: count) {
                    let areInterconnected = combination.allSatisfy { current in
                        let others = Set([computer]).union(Set(combination).subtracting([current]))
                        return connectedComputersByComputer[current, default: []].isSuperset(of: others)
                    }
                    
                    guard areInterconnected else {
                        continue
                    }
                    
                    let interconnectedComputers = Set([computer] + combination)
                    if interconnectedComputers.count > largestSet.count {
                        largestSet = interconnectedComputers
                    }
                }
            }
        }
        
        return largestSet.sorted().joined(separator: ",")
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
