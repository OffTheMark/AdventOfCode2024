//
//  Day9.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-04.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Algorithms
import Collections

struct Day9: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day9",
            abstract: "Solve day 9 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let disk = try disk()
        
        printTitle("Part 1", level: .title1)
        let fileSystemChecksum = part1(disk)
        print("Filesystem checksum of compacted disk:", fileSystemChecksum, terminator: "\n\n")
    }
    
    func disk() throws -> [DiskSlot] {
        let diskMap = try readFile().compactMap {
            Int(String($0))
        }
        var currentFileID = 0
        var isFile = true
        var disk = [DiskSlot]()
        
        for number in diskMap {
            if isFile {
                disk.append(contentsOf: [DiskSlot](repeating: .file(id: currentFileID), count: number))
                currentFileID += 1
            }
            else {
                disk.append(contentsOf: [DiskSlot](repeating: .freeSpace, count: number))
            }
            
            isFile.toggle()
        }
        return disk
    }
    
    func part1(_ disk: [DiskSlot]) -> Int {
        var indicesOfFiles: Deque<Int> = disk.indexed().reduce(into: []) { result, pair in
            let (index, slot) = pair
            if case .file = slot {
                result.append(index)
            }
        }
        var indicesOfFreeSpaces: Deque<Int> = disk.indexed().reduce(into: []) { result, pair in
            let (index, slot) = pair
            if case .freeSpace = slot {
                result.append(index)
            }
        }
        var compactedDisk = disk
        
        while let fileIndex = indicesOfFiles.popLast(), let freeSpaceIndex = indicesOfFreeSpaces.popFirst() {
            if freeSpaceIndex > fileIndex {
                break
            }
            
            compactedDisk.swapAt(fileIndex, freeSpaceIndex)
            indicesOfFiles.prepend(freeSpaceIndex)
            indicesOfFreeSpaces.append(fileIndex)
        }
        
        let checksum = compactedDisk.indexed().reduce(into: 0, { checksum, pair in
            let (index, slot) = pair
            if case .file(let id) = slot {
                checksum += id * index
            }
        })
        return checksum
    }
}

enum DiskSlot {
    case freeSpace
    case file(id: Int)
}
