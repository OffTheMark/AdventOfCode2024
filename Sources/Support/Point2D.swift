//
//  Point2D.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-08.
//

import Foundation

// MARK: Point2D

struct Point2D: Hashable {
    var x: Int
    var y: Int
    
    func translation(to other: Point2D) -> Translation2D {
        Translation2D(deltaX: other.x - x, deltaY: other.y - y)
    }
    
    func manhattanDistance(to position: Point2D) -> Int {
        abs(x - position.x) + abs(y - position.y)
    }
    
    func adjacentPoints(includingDiagonals includesDiagonals: Bool) -> Set<Point2D> {
        var translations: [Translation2D] = [
            .up,
            .right,
            .down,
            .left,
        ]
        if includesDiagonals {
            translations += [
                .upRight,
                .downRight,
                .downLeft,
                .upLeft,
            ]
        }
        
        return Set(translations.map({ applying($0) }))
    }
    
    mutating func apply(_ translation: Translation2D) {
        x += translation.deltaX
        y += translation.deltaY
    }
    
    func applying(_ translation: Translation2D) -> Self {
        var copy = self
        copy.apply(translation)
        return copy
    }
    
    static let zero = Self(x: 0, y: 0)
}
