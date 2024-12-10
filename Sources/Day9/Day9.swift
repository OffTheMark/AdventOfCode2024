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
        
        printTitle("Part 2", level: .title1)
        let clock = ContinuousClock()
        let (elapsedTime, fileSystemChecksumAfterCompactingWithNewMethod) = clock.measure {
            part2(disk: disk)
        }
        print("Filesystem checksum of compacted disk using new method:", fileSystemChecksumAfterCompactingWithNewMethod)
        print("Elapsed time: \(elapsedTime)")
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
    
    func part2(disk: [DiskSlot]) -> Int {
        var indicesByFile = [Int: Range<Int>]()
        var freeSpaceBlocks = [Range<Int>]()
        
        for (index, slot) in disk.enumerated() {
            switch slot {
            case .file(let fileID):
                if let range = indicesByFile[fileID] {
                    let newRange = range.lowerBound ..< index + 1
                    indicesByFile[fileID] = newRange
                }
                else {
                    indicesByFile[fileID] = index ..< index + 1
                }
                
            case .freeSpace:
                if let lastBlock = freeSpaceBlocks.last, lastBlock.upperBound == index {
                    freeSpaceBlocks[freeSpaceBlocks.endIndex - 1] = lastBlock.lowerBound ..< index + 1
                }
                else {
                    freeSpaceBlocks.append(index ..< index + 1)
                }
            }
        }
        var filesToMove = Deque(indicesByFile.keys.sorted())
        
        while let fileID = filesToMove.popLast() {
            let fileBlock = indicesByFile[fileID]!
            
            // We find the first free block left of the file that is big enough to fit the file.
            guard let indexFreeBlockPair = freeSpaceBlocks.enumerated().first(where: { _, block in
                block.upperBound <= fileBlock.lowerBound && block.count >= fileBlock.count
            }) else {
                continue
            }
            
            let (freeBlockIndex, freeBlock) = indexFreeBlockPair
            let newFileBlock = freeBlock.lowerBound ..< freeBlock.lowerBound + fileBlock.count
            
            // Move the file to its new location.
            indicesByFile[fileID] = newFileBlock
            
            if freeBlock.count > fileBlock.count {
                // If the free block was bigger than the file block, we update the free block to be the remaining block.
                let newFreeBlock = newFileBlock.upperBound ..< freeBlock.upperBound
                freeSpaceBlocks[freeBlockIndex] = newFreeBlock
            }
            else {
                // Otherwise if it was the the same size as the file block, we simply remove it.
                freeSpaceBlocks.remove(at: freeBlockIndex)
            }
        }
        
        let checksum = indicesByFile.reduce(into: 0) { checksum, element in
            let (fileID, block) = element
            checksum += fileID * block.reduce(0, +)
        }
        return checksum
    }
}

enum DiskSlot: Equatable {
    case freeSpace
    case file(id: Int)
}
