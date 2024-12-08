//
//  Translation2D.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-08.
//

import Foundation

// MARK: Translation2D

struct Translation2D: Hashable {
    var deltaX: Int
    var deltaY: Int
    
    var normalized: Translation2D {
        let greatestMagnitude = max(abs(deltaX), abs(deltaY))
        
        if greatestMagnitude == 0 {
            return self
        }
        
        guard deltaX.isDivisible(by: greatestMagnitude), deltaY.isDivisible(by: greatestMagnitude) else {
            return self
        }
        
        return Self(
            deltaX: deltaX / greatestMagnitude,
            deltaY: deltaY / greatestMagnitude
        )
    }
    
    static let up = Self(deltaX: 0, deltaY: -1)
    static let upRight = Self(deltaX: 1, deltaY: -1)
    static let right = Self(deltaX: 1, deltaY: 0)
    static let downRight = Self(deltaX: 1, deltaY: 1)
    static let down = Self(deltaX: 0, deltaY: 1)
    static let downLeft = Self(deltaX: -1, deltaY: 1)
    static let left = Self(deltaX: -1, deltaY: 0)
    static let upLeft = Self(deltaX: -1, deltaY: -1)
    
    static func * (lhs: Self, rhs: Int) -> Self {
        Self(deltaX: lhs.deltaX * rhs, deltaY: lhs.deltaY * rhs)
    }
    
    static func *= (lhs: inout Self, rhs: Int) {
        lhs = lhs * rhs
    }
    
    static func * (lhs: Int, rhs: Self) -> Self {
        Self(deltaX: rhs.deltaX * lhs, deltaY: rhs.deltaY * lhs)
    }
    
    static prefix func - (translation: Self) -> Self {
        Self(deltaX: -translation.deltaX, deltaY: -translation.deltaY)
    }
}
