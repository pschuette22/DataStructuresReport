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



struct SortComparisonView: View {
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
            HStack {
                // Chart View
                ZStack {
                    Chart {
                        ForEach(measurements, id: \.strategy) {
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
                // Custom Legend view
                VStack {
                    Text("Strategies")
                        .font(.title2)
                    ForEach(ArraySortingStrategy.allCases.sorted(by: { $0.title < $1.title })) { strategy in
                        let isStrategyShown = chartBounds.strategies.contains(strategy)
                        HStack {
                            Rectangle()
                                .frame(width: 20, height: 10, alignment: .leading)
                                .foregroundColor(strategy.color)
                            Spacer(minLength: 2)
                            Text(strategy.title)
                                .frame(alignment: .trailing)
                        }
                        .padding(.horizontal, 8)
                        .frame(width: 130)
                        .opacity(isStrategyShown ? 1.0 : 0.7)
                        .onTapGesture {
                            if let index = chartBounds.strategies.firstIndex(of: strategy) {
                                chartBounds.strategies.remove(at: index)
                            } else {
                                chartBounds.strategies.append(strategy)
                            }
                        }
                    }
                }
                .frame(alignment: .top)
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

extension SortComparisonView {
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
    SortComparisonView() {
        10 * $0
    }
}
