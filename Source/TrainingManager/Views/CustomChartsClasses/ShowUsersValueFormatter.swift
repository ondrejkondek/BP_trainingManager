//
//  ShowUsersValueFormatter.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 05/03/2021.
//

import Foundation
import Charts

final class ShowUsersXAxisValueFormatter : NSObject, IAxisValueFormatter {

    var labels = [String]()
    
    /// This code is highly inspired by the GitHub repository Charts from Sagar Sukode
    /// Sagar Sukode, Charts, (2018), GitHub repository
    /// Source: https://github.com/sagarsukode/Charts
    ///
    /// Sets labels for groupedBarChart - between two bars
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        let count = self.labels.count
        if let axis = axis, count > 0 {
            
            let factor = axis.axisMaximum / Double(count)
            let index = Int((value / factor).rounded())

            if (index >= 0) && (index < count) {
                return self.labels[index]
            }
        
            return ""
        }
        else {
            return ""
        }
    }
}
