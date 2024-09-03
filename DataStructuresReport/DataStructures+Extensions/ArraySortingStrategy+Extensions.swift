//
//  ArraySortingStrategy+Extensions.swift
//  DataStructuresReport
//
//  Created by Peter Schuette on 9/2/24.
//

import Foundation
import DataStructures
import SwiftUI
import Charts

extension ArraySortingStrategy {
    var title: String {
        switch self {
        case .bubble: return "Bubble Sort"
        case .heap: return "Heap Sort"
        case .merge: return "Merge Sort"
        case .default: return "Swift Default"
        }
    }
    
    var color: Color {
        switch self {
        case .bubble: return .red
        case .heap: return .blue
        case .merge: return .green
        case .default: return .yellow
        }
    }
}
