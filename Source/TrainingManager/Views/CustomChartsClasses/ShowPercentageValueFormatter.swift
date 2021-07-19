//
//  ShowPercentageValueFormatter.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 23/03/2021.
//

import Foundation
import Charts

class ShowPercentageValueFormatter: NSObject, IValueFormatter {

    var sum: Int
    
    init(sum: Int) {
        self.sum = sum
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        
        let percentage = Double(value) / Double(sum) * 100
        return String(format: "%.1f", percentage) + "%"
    }
}
