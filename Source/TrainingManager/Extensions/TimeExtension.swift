//
//  TimeExtension.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 18/03/2021.
//

import Foundation

extension Time {
    
    /// Converts seconds to String in format: 00h:00m:00s
    /// - Parameter seconds: seconds to be converted
    /// - Parameter mininterval: interval defining string values
    /// - Returns: String of time trained
    func getTimeFromSeconds(_ seconds: Int, minretval: String) -> String {
        
        let hours = seconds / 3600
        let minutes = (seconds - (hours * 3600)) / 60
        
        if minretval == "minutes" {
            
            if hours == 0 {
                return "\(minutes)m"
            }
            
            return "\(hours)h:\(minutes)m"
        }
        else if minretval == "seconds" {

            let seconds = seconds - (hours * 3600) - (minutes * 60)
            
            return "\(hours)h:\(minutes)m:\(seconds)s"
        }
        
        return ""
    }
    
    /// - Parameter seconds: seconds to be converted
    /// - Returns: Time
    func secToHoursMinSec(seconds: Int) -> Time {
        let time = Time(hours: (seconds / 3600), minutes: ((seconds % 3600) / 60), seconds: ((seconds % 3600) % 60))
        return time
    }
    
    /// - Parameters: hours, minutes, seconds
    /// - Returns: Text of the time
    func timeToString(hours: Int, minutes: Int, seconds: Int) -> String{
        let labelText = String(format: "%02d", hours) + ":" + String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
        return labelText
    }
}
