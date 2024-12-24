//
//  Day24.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-23.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import RegexBuilder

struct Day24: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day24",
            abstract: "Solve day 24 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let (initialValues, wires) = try parse()
        
        let clock = ContinuousClock()
        printTitle("Part 1", level: .title1)
        let (part1Duration, number) = clock.measure {
            part1(initialValues: initialValues, wires: wires)
        }
        print("Decimal number output on wires starting with z:", number)
        print("Elapsed time:", part1Duration, terminator: "\n\n")
    }
    
    private func parse() throws -> (initialValues: [InitialValue], wires: [Wire]) {
        let input = try readFile()
        let parts = input.components(separatedBy: "\n\n")
        
        let initialValues = parts[0].components(separatedBy: "\n").compactMap(InitialValue.init)
        let wires = parts[1].components(separatedBy: "\n").compactMap(Wire.init)
        return (initialValues, wires)
    }
    
    private func part1(initialValues: [InitialValue], wires: [Wire]) -> Int {
        var valuesByWire = [String: Bool]()
        var wiresByOutput = [String: Wire]()
        var zWires = Set<String>()
        
        for initialValue in initialValues {
            valuesByWire[initialValue.wire] = initialValue.value
            
            if initialValue.wire.starts(with: "z") {
                zWires.insert(initialValue.wire)
            }
        }
        
        for wire in wires {
            wiresByOutput[wire.output] = wire
            
            if wire.lhs.starts(with: "z") {
                zWires.insert(wire.lhs)
            }
            if wire.rhs.starts(with: "z") {
                zWires.insert(wire.rhs)
            }
            if wire.output.starts(with: "z") {
                zWires.insert(wire.output)
            }
        }
        
        while !zWires.allSatisfy({ valuesByWire[$0] != nil }) {
            for (output, wire) in wiresByOutput where valuesByWire[output] == nil {
                guard let lhs = valuesByWire[wire.lhs], let rhs = valuesByWire[wire.rhs] else {
                    continue
                }
                
                valuesByWire[output] = wire.gate.output(lhs, rhs)
                wiresByOutput.removeValue(forKey: output)
            }
        }
        
        let valuesOfZWires = zWires.sorted().map({ valuesByWire[$0]! })
        return valuesOfZWires.enumerated().reduce(into: 0) { number, element in
            let (index, value) = element
            
            if value {
                number += Int(pow(2, Double(index)))
            }
        }
    }
}

private struct InitialValue {
    let wire: String
    let value: Bool
}

extension InitialValue {
    init?(rawValue: String) {
        let regex = Regex {
            let wire = Capture {
                OneOrMore {
                    ("a" ... "z").union("0" ... "9")
                }
            } transform: {
                String($0)
            }
            let value = Capture {
                ChoiceOf {
                    "0"
                    "1"
                }
            } transform: {
                $0 == "1"
            }
            
            wire
            ": "
            value
        }
        
        guard let match = rawValue.firstMatch(of: regex) else {
            return nil
        }
        
        self.wire = match.output.1
        self.value = match.output.2
    }
}

private struct Wire {
    let lhs: String
    let gate: Gate
    let rhs: String
    let output: String
}

extension Wire {
    init?(rawValue: String) {
        let regex = Regex {
            let wire = Capture {
                OneOrMore {
                    ("a" ... "z").union("0" ... "9")
                }
            } transform: {
                String($0)
            }
            
            let gate = TryCapture {
                ChoiceOf {
                    "AND"
                    "OR"
                    "XOR"
                }
            } transform: {
                Gate(rawValue: String($0))
            }
            
            wire
            " "
            gate
            " "
            wire
            " -> "
            wire
        }
        
        guard let match = rawValue.firstMatch(of: regex) else {
            return nil
        }
        
        self.lhs = match.output.1
        self.gate = match.output.2
        self.rhs = match.output.3
        self.output = match.output.4
    }
}

private enum Gate: String {
    case and = "AND"
    case or = "OR"
    case xor = "XOR"
    
    func output(_ lhs: Bool, _ rhs: Bool) -> Bool {
        switch self {
        case .and:
            lhs && rhs
            
        case .or:
            lhs || rhs
            
        case .xor:
            lhs != rhs
        }
    }
}
