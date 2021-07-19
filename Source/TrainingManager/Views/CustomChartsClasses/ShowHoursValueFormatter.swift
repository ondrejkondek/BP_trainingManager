//
//  ShowHoursValueFormatter.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 25/02/2021.
//

import Foundation
import Charts

final class ShowHoursValueFormatter: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(format: "%.0f", value) + " h"
    }
}
