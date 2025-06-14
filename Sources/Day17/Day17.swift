//
//  Day17.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-16.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections
import RegexBuilder

struct Day17: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day17",
            abstract: "Solve day 17 puzzle"
        )
    }
    
    @Argument(
        help: "Puzzle input path",
        transform: { URL(filePath: $0, relativeTo: nil) }
    )
    var puzzleInputURL: URL
    
    func run() throws {
        let computer = Computer(rawValue: try readFile())!
        
        let clock = ContinuousClock()
        printTitle("Part 1", level: .title1)
        let (part1Duration, output) = clock.measure {
            part1(computer)
        }
        print("Output:", output.map(String.init).joined(separator: ","))
        print("Elapsed time:", part1Duration, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let (part2Duration, registerA) = clock.measure {
            part2(computer)
        }
        print("Lowest positive initial value for register A:", registerA)
        print("Elapsed time:", part2Duration, terminator: "\n\n")
    }
    
    private func part1(_ computer: Computer) -> [Int] {
        var computer = computer
        return computer.run()
    }
    
    private func part2(_ computer: Computer) -> Int {
        for registerA in 0... {
            var copy = computer
            copy.registerA = registerA
            let output = copy.run()
            
            if output == copy.program {
                return registerA
            }
        }
        
        fatalError("Should not happen")
    }
}

private enum Instruction: Int {
    case adv = 0
    case bxl = 1
    case bst = 2
    case jnz = 3
    case bxc = 4
    case out = 5
    case bdv = 6
    case cdv = 7
}

private struct Computer {
    var registerA: Int
    var registerB: Int
    var registerC: Int
    let program: [Int]
    
    mutating func run() -> [Int] {
        var instructionPointer = 0
        var output = [Int]()
        
        while program.indices.contains(instructionPointer), program.indices.contains(instructionPointer + 1) {
            guard let instruction = Instruction(rawValue: program[instructionPointer]) else {
                instructionPointer += 2
                continue
            }
            
            let literalOperand = program[instructionPointer + 1]
            let comboOperand = comboOperand(for: literalOperand)
            
            switch instruction {
            case .adv:
                let numerator = registerA
                let denominator = Int(pow(2, Float(comboOperand)))
                registerA = numerator / denominator
                
            case .bxl:
                registerB = registerB ^ literalOperand
                
            case .bst:
                registerB = comboOperand % 8
                
            case .jnz:
                if registerA != 0 {
                    instructionPointer = literalOperand
                    continue
                }
                
            case .bxc:
                registerB = registerB ^ registerC
                
            case .out:
                output.append(comboOperand % 8)
                
            case .bdv:
                let numerator = registerA
                let denominator = Int(pow(2, Float(comboOperand)))
                registerB = numerator / denominator
                
            case .cdv:
                let numerator = registerA
                let denominator = Int(pow(2, Float(comboOperand)))
                registerC = numerator / denominator
            }
            
            instructionPointer += 2
        }
        
        return output
    }
    
    func comboOperand(for operand: Int) -> Int {
        switch operand {
        case 0, 1, 2, 3:
            operand
            
        case 4:
            registerA
            
        case 5:
            registerB
            
        case 6:
            registerC
            
        default:
            operand
        }
    }
}

extension Computer {
    init?(rawValue: String) {
        let regex = Regex {
            let registerValue = TryCapture {
                OneOrMore(.digit)
            } transform: {
                Int(String($0))
            }
            
            let program = Regex {
                "Program: "
                
                TryCapture {
                    One(.digit)
                    ZeroOrMore {
                        ","
                        One(.digit)
                    }
                } transform: {
                    String($0).components(separatedBy: ",").compactMap(Int.init)
                }
            }
            
            "Register A: "
            registerValue
            "\nRegister B: "
            registerValue
            "\nRegister C: "
            registerValue
            "\n\n"
            program
        }
        
        guard let match = rawValue.firstMatch(of: regex) else {
            return nil
        }
        
        self.registerA = match.output.1
        self.registerB = match.output.2
        self.registerC = match.output.3
        self.program = match.output.4
    }
}
