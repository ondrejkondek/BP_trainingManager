//
//  ShowLastMonthValueFormatter.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 22/03/2021.
//

import Foundation
import Charts

final class ShowLastMonthValueFormatter : NSObject, IAxisValueFormatter {

    var labels: [String]!
    
    init(labels: [String]) {
        self.labels = labels
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        let val = Int(value)
        if ((val >= 0) && (val < 30)){
            return self.labels[val]
        }
        else{
            return ""
        }
    }
}

final class ShowLast3MonthsValueFormatter : NSObject, IAxisValueFormatter {

    var labels: [String]!
    
    init(labels: [String]) {
        self.labels = labels
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        let val = Int(value)
        if ((val >= 0) && (val < 90)){
            return self.labels[val]
        }
        else{
            return ""
        }
    }
}

final class ShowLast6MonthsValueFormatter : NSObject, IAxisValueFormatter {

    var labels: [String]!
    
    init(labels: [String]) {
        self.labels = labels
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        let val = Int(value)
        if ((val >= 0) && (val < 180)){
            return self.labels[val]
        }
        else{
            return ""
        }
    }
}
final class ShowLastYearValueFormatter : NSObject, IAxisValueFormatter {

    var labels: [String]!
    
    init(labels: [String]) {
        self.labels = labels
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        let val = Int(value)
        if ((val >= 0) && (val < 365)){
            return self.labels[val]
        }
        else{
            return ""
        }
    }
}
