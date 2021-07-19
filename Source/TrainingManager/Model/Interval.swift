//
//  Interval.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 22/03/2021.
//

import Foundation

/// A Class representing different intervals (number of days) with their captions
class Interval {
    
    /// actual stored interval in class represented by Int
    var actualInterval: Int!
    
    /// Initialization of a object - need to set an init value of interval
    init(actualInterval: Int) {
        self.actualInterval = actualInterval
    }
    
    /// Getter of an actual interval
    func getInterval() -> (String, Int){
        switch self.actualInterval {
        case 0:
            return ("LAST 6 MONTHS", 180)
        case 1:
            return ("LAST 3 MONTHS", 90)
        case 2:
            return ("LAST MONTH", 30)
        case 3:
            return ("LAST WEEK", 7)
        case 4:
            return ("LAST YEAR", 365)
        default:
            return ("LAST WEEK", 7)
        }
    }
    
    /// Move forward between intervals
    func next(){
        self.actualInterval = self.actualInterval + 1
        self.controlInterval()
    }
    
    /// Move back between intervals
    func previous(){
        self.actualInterval = self.actualInterval - 1
        self.controlInterval()
    }
    
    /// Preventing an overflow of of the interval
    func controlInterval(){
        if self.actualInterval > 4 {
            self.actualInterval = 0
        }
        if self.actualInterval < 0 {
            self.actualInterval = 4
        }
    }
}
