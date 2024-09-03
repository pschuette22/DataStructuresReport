//
//  DataStructuresReportApp.swift
//  DataStructuresReport
//
//  Created by Peter Schuette on 9/2/24.
//

import SwiftUI

@main
struct DataStructuresReportApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Comparision of Data Structures")
                .font(.largeTitle)
                .padding(.all, 24)
            SortComparisonView()
        }
    }
}
