//
//  DateExtension.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 03/03/2021.
//

import Foundation

extension Date {
    
    /// - Returns: Date of last week -> X days back date
    func getXdaysAgoDate(daysAgo: Int) -> Date {
       
        let calendar = Calendar.current
        let dateLastWeek = Calendar.current.date(byAdding: .day, value: -(daysAgo) + 1, to: Date())!
        let components = calendar.dateComponents([.year, .day, .month], from: dateLastWeek)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yyyy HH:mm"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        let date = formatter.date(from: String(components.day!) + ":" + String(components.month!) + ":" + String(components.year!) + " " + "00:00")

        return date!
    }
    
    /// - Returns: start/end time of the given date (00:00 / 23:59)
    func getDayTimes(start: Bool, date: Date) -> Date {
       
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .day, .month], from: date)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yyyy HH:mm"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        
        if start {
            let date = formatter.date(from: String(components.day!) + ":" + String(components.month!) + ":" + String(components.year!) + " " + "00:00")
            return date!
        }
        else {
            let date = formatter.date(from: String(components.day!) + ":" + String(components.month!) + ":" + String(components.year!) + " " + "23:59")
            return date!
        }
    }
    
    /// - Returns: if the day is today True else false
    func isToday() -> Bool {
        
        let calendar = Calendar.current
        let compDate = calendar.dateComponents([.year, .day, .month], from: self)
        let compToday = calendar.dateComponents([.year, .day, .month], from: Date())
        
        if (compDate.year == compToday.year && compDate.day == compToday.day && compDate.month == compToday.month) {
            return true
        }
        else {
            return false
        }
    }
    
    /// - Returns: number of days between given date and today
    func howManyDaysAgo() -> Int {

        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: Date())

        let daysAgo = calendar.dateComponents([.day], from: date1, to: date2)

        return abs(daysAgo.day ?? 0)
    }
    
    /// Creates a type Date out of parameters with default time 00:00
    /// - Parameter year:
    /// - Parameter month:
    /// - Parameter day:
    /// - Returns: Date got from parameters
    func getDate(year: Int, month: Int, day: Int) -> Date {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yyyy HH:mm"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        let date = formatter.date(from: String(day) + ":" + String(month) + ":" + String(year) + " " + "00:00")

        return date!
    }
    
    /// - Returns: array of strings - Names of last week days
    func getDaysLabels() -> [String] {
        
        var labels = [String]()
        var daysNum = [Int]()
        let calendar = Calendar.current
        
        daysNum.append(calendar.component(.weekday, from: calendar.date(byAdding: .day, value: -6, to: Date())!))
        daysNum.append(calendar.component(.weekday, from: calendar.date(byAdding: .day, value: -5, to: Date())!))
        daysNum.append(calendar.component(.weekday, from: calendar.date(byAdding: .day, value: -4, to: Date())!))
        daysNum.append(calendar.component(.weekday, from: calendar.date(byAdding: .day, value: -3, to: Date())!))
        daysNum.append(calendar.component(.weekday, from: calendar.date(byAdding: .day, value: -2, to: Date())!))
        daysNum.append(calendar.component(.weekday, from: calendar.date(byAdding: .day, value: -1, to: Date())!))
        
        for day in daysNum {
            switch day {
            case 1:
                labels.append("Sun")
            case 2:
                labels.append("Mon")
            case 3:
                labels.append("Tue")
            case 4:
                labels.append("Wed")
            case 5:
                labels.append("Thu")
            case 6:
                labels.append("Fri")
            case 7:
                labels.append("Sat")
            default:
                break
            }
        }
        
        labels.append("Today")
        
        return labels
    }
    
    /// - Parameter to: date to be compared with self
    /// - Returns: number of seconds - difference between 2 dates
    func secondsDifference(to: Date) -> Int {
        let diffComponents = Calendar.current.dateComponents([.second], from: self, to: to)
        let seconds = diffComponents.second
        
        return abs(seconds ?? 0)
    }
}
