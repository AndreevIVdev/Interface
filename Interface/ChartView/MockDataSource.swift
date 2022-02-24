//
//  MockDataSource.swift
//  Interface
//
//  Created by Eugene Dudkin on 24.02.2022.
//

import Foundation

class MockDataSource {
    func generateRandomEntries() -> [ChartCandle] {
        var result: [ChartCandle] = []
        for i in 0 ..< 1000 {
            let value = 10 * i - (i % 2 == 0 ? 100 : 10)
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            var date = Date()
            date.addTimeInterval(TimeInterval(24 * 60 * 60 * i))
            
            result.append(ChartCandle(value: value, label: formatter.string(from: date)))
        }
        return result
    }
}
