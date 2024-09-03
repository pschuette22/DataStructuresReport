//
//  tMeasurementRepo.swift
//  DataStructuresReport
//
//  Created by Peter Schuette on 9/2/24.
//

import Foundation
import DataStructures

struct SortMeasurement: Identifiable {
    typealias ID = String
    var id: String {
        strategy.title + " \(elements)"
    }
    
    let strategy: ArraySortingStrategy
    let elements: Int
    let time: Double
}

final class MeasurementRepo {
    private struct MeasurementKey: Hashable {
        let strategy: ArraySortingStrategy
        let elements: Int
    }

    private let lock = NSLock()
    private var measurements = [MeasurementKey: SortMeasurement]()
    
    static func time(_ function: @escaping () -> Void) -> Double {
        let start = CFAbsoluteTimeGetCurrent()
        function()
        return CFAbsoluteTimeGetCurrent() - start
    }
    
    private func calculateTimeComplexity(
        for strategies: [ArraySortingStrategy],
        elements: Int
    ) -> [SortMeasurement] {
        // Lazy to avoid initializing if we have cached measurements
        lazy var array = (0...elements).reduce(into: [Int]()) { partialResult, index in
            partialResult.append(Int.random(in: 0...Int.max))
        }

        return strategies.reduce(into: [SortMeasurement]()) { partialResult, strategy in
            let key = MeasurementKey(strategy: strategy, elements: elements)
            if let cached = measurements[key] {
                partialResult.append(cached)
            } else {
                var copy = array
                // Trigger a copy on write before timing
                copy[0] = copy[elements / 2]
                let time = Self.time {
                    copy.sort(using: strategy)
                }
                let measurement = SortMeasurement(strategy: strategy, elements: elements, time: time)
                lock.lock()
                measurements[key] = measurement
                lock.unlock()
                partialResult.append(measurement)
            }
        }
    }
    
    func getMeasurements(for strategies: [ArraySortingStrategy], lowerBound: Int, upperBound: Int) async -> [SortMeasurement] {
        let task = Task<[SortMeasurement], Never>() { [weak self] in
            var measurements = [SortMeasurement]()
            for elements in stride(from: lowerBound, to: upperBound, by: (upperBound - lowerBound) / 10) {
                guard let calculatedMeasurements = self?.calculateTimeComplexity(for: strategies, elements: elements) else {
                    break
                }
                measurements.append(contentsOf: calculatedMeasurements)
            }

            return measurements
        }
        
        return await task.value
    }
}
