//
//  ClockExtensions.swift
//  AdventOfCode2024
//
//  Created by Marc-Antoine Malépart on 2024-12-09.
//

import Foundation

extension Clock {
    func measure<Result>(_ work: () throws -> Result) rethrows -> (duration: Instant.Duration, result: Result) {
        var result: Result!
        let duration = try measure {
            result = try work()
        }
        return (duration, result)
    }
}
