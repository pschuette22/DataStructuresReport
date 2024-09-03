//
//  ContentView.swift
//  DataStructuresReport
//
//  Created by Peter Schuette on 9/2/24.
//

import SwiftUI
import DataStructures
import Charts

struct Measurement: Hashable {
    let strategy: ArraySortingStrategy
    let elements: Int
}



struct ContentView: View {
    typealias BoundCalculator = (Int) -> Int

    @State private var chartBounds: ChartBounds = .init()
    @State private var isCalculatingComplexity = false
    @State private var measurements = [SortMeasurement]()

    private var measurementRepo = MeasurementRepo()
    private var boundCalculator: BoundCalculator
    
    init(
        _ boundCalculator: @escaping BoundCalculator = { $0 * 100 }
    ) {
        self.boundCalculator = boundCalculator
    }

    var body: some View {
        VStack {
            ZStack {
                Chart {
                    ForEach(measurements) {
                        LineMark(
                            x: .value("Elements", $0.elements),
                            y: .value("Time", $0.time),
                            series: .value("Strategy", $0.strategy.title)
                        )
                        .foregroundStyle($0.strategy.color)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 10))
                    
                }
                .chartXScale(
                    domain: [boundCalculator(5), boundCalculator(Int(chartBounds.n))]
                )
                .chartXAxisLabel("Elements Sorted")
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartYAxisLabel("Seconds")
                .zIndex(0)

                if isCalculatingComplexity {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(alignment: .center)
                        .zIndex(1)
                }
            }

            Spacer()

            Slider(
                value: $chartBounds.n,
                in: 10...25,
                step: 1
            )
            .task(id: $chartBounds.wrappedValue) {
                isCalculatingComplexity = true
                measurements = await measurementRepo.getMeasurements(
                    for: chartBounds.strategies,
                    lowerBound: boundCalculator(5),
                    upperBound:  boundCalculator(Int(chartBounds.n))
                )
                isCalculatingComplexity = false
            }

            Text("Time complexity of sort functions from \(boundCalculator(5)) to \(boundCalculator(Int(chartBounds.n))) elements")
            
        }
        .padding()
    }
}

// MARK: - ChartBounds

extension ContentView {
    struct ChartBounds: Identifiable, Equatable {
        typealias ID = String
        var id: String {
            "\(n), " + strategies.map { $0.title }.joined(separator: ", ")
        }
        
        var n = 10.0
        var strategies = ArraySortingStrategy.allCases
    }
}

#Preview {
    ContentView() {
        10 * $0
    }
}
