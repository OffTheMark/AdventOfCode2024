//
//  Grid2D.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-04.
//

import Foundation

// MARK: Grid2D

struct Grid2D<Value> {
    private(set) var valuesByPosition: [Point2D: Value]
    
    let frame: Frame2D
    
    var points: Dictionary<Point2D, Value>.Keys { valuesByPosition.keys }
    
    init(frame: Frame2D) {
        self.valuesByPosition = [:]
        self.frame = frame
    }
    
    func hasValue(at position: Point2D) -> Bool {
        valuesByPosition.keys.contains(position)
    }
    
    func isPointInside(_ point: Point2D) -> Bool {
        frame.contains(point)
    }
    
    @discardableResult
    mutating func removeValue(forPoint point: Point2D) -> Value? {
        valuesByPosition.removeValue(forKey: point)
    }
    
    mutating func updateValue(_ value: Value, forPoint point: Point2D) -> Value? {
        valuesByPosition.updateValue(value, forKey: point)
    }
    
    subscript(point: Point2D) -> Value? {
        get {
            valuesByPosition[point]
        }
        set {
            valuesByPosition[point] = newValue
        }
    }
    
    subscript(point: Point2D, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            valuesByPosition[point, default: defaultValue()]
        }
        set {
            valuesByPosition[point, default: defaultValue()] = newValue
        }
    }
}

extension Grid2D: Sequence {
    typealias Iterator = Dictionary<Point2D, Value>.Iterator
    
    func makeIterator() -> Iterator {
        valuesByPosition.makeIterator()
    }
}

extension Grid2D {
    init(rawValue: String, valueForCharacter: @escaping (Character) -> Value?) {
        let lines = rawValue.components(separatedBy: .newlines)
        
        var size = Size2D(width: 0, height: lines.count)
        let valuesByPosition: [Point2D: Value] = lines.enumerated().reduce(into: [:], { result, element in
            let (y, line) = element
            
            size.width = Swift.max(size.width, line.count)
            
            for (x, character) in line.enumerated() {
                guard let value = valueForCharacter(character) else {
                    continue
                }
                
                let position = Point2D(x: x, y: y)
                result[position] = value
            }
        })
        
        self.valuesByPosition = valuesByPosition
        self.frame = Frame2D(origin: .zero, size: size)
    }
}

extension Grid2D where Value: RawRepresentable, Value.RawValue == Character {
    init(rawValue: String) {
        self.init(rawValue: rawValue, valueForCharacter: Value.init)
    }
    
    func debugOutput() -> String {
        frame.rows.map({ y in
            String(
                frame.columns.map({ x in
                    let point = Point2D(x: x, y: y)
                    return if let value = self[point] {
                        value.rawValue
                    }
                    else {
                        "."
                    }
                })
            )
        })
        .joined(separator: "\n")
    }
}

// MARK: Frame2D

struct Frame2D {
    var origin: Point2D
    var size: Size2D
    
    func contains(_ point: Point2D) -> Bool {
        rows.contains(point.y) && columns.contains(point.x)
    }
    
    var columns: Range<Int> {
        origin.x ..< origin.x + size.width
    }
    var rows: Range<Int> {
        origin.y ..< origin.y + size.height
    }
    
    var minX: Int { origin.x }
    var minY: Int { origin.y }
    var maxX: Int {
        origin.x + size.width - 1
    }
    var maxY: Int {
        origin.y + size.height - 1
    }
}

// MARK: - Size2D

struct Size2D: Hashable {
    var width: Int
    var height: Int
    
    static let zero = Self(width: 0, height: 0)
}
