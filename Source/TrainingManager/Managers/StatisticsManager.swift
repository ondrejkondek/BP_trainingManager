//
//  StatisticsManager.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 24/03/2021.
//

import Foundation

/// Manager of Statistics that are presented to details view controllers
class StatisticsManager {
    
    var records: [Record]
    
    init(records: [Record]) {
        self.records = records
    }

    func averageTrainingTime() -> String {
        
        let times = records.compactMap({ $0.time})
        
        let sum = times.reduce(0, +)
        let count = times.count
        
        if (count == 0){
            return Time().getTimeFromSeconds(0, minretval: "minutes")
        }
        
        let avg = Int(sum) / Int(count)

        return Time().getTimeFromSeconds(avg, minretval: "minutes")
    }
    
    func weekAverageTrainingNumber() -> String{
       
        let rawDates = records.compactMap({ $0.date})
        let dates = rawDates.sorted(by: {$0 < $1})
        
        let first = dates.first ?? Date()
        let trainingDays = Calendar.current.dateComponents([.day], from: first, to: Date()).day ?? 0
        
        let sum = dates.count // number of trainings
        let weeks = trainingDays / 7 + 1

        let result = sum / weeks

    
        return String(result)
    }
    
    func weekAverageTrainingTime() -> String{
       
        let rawDates = records.compactMap({ $0.date})
        let dates = rawDates.sorted(by: {$0 < $1})
        
        let first = dates.first ?? Date()
        let trainingDays = Calendar.current.dateComponents([.day], from: first, to: Date()).day ?? 0
        
        let sum = records.compactMap({ $0.time }).reduce(0, +)
        let weeks = trainingDays / 7 + 1

        let result = Int(sum) / weeks

        return Time().getTimeFromSeconds(result, minretval: "minutes")
    }
    
    func longestTraining() -> String {

        let times = records.compactMap({ $0.time})
        let max = Int(times.max() ?? 0)
        
        return Time().getTimeFromSeconds(max, minretval: "minutes")
    }
    
    func trainingStreak() -> String {
        
        let rawDates = records.compactMap({ $0.date})
        var streak = 1
        var maxStreak = 0
        
        let dates = rawDates.sorted(by: {$0 < $1})

        var lastDate = dates.first ?? Date()
        var toCompare = dates.first ?? Date()
        for date in dates {
            
            if lastDate == date {
                continue
            }
            
            if streak > 1 {
                toCompare = Calendar.current.date(byAdding: .day, value: 1, to: toCompare)!
            }
            else{
                toCompare = Calendar.current.date(byAdding: .day, value: 1, to: lastDate)!
            }
            let date1 = Calendar.current.dateComponents([.year, .day, .month], from: toCompare)
            let date2 = Calendar.current.dateComponents([.year, .day, .month], from: date)
     
            if ((date1.year == date2.year) &&
                (date1.month == date2.month) &&
                    (date1.day == date2.day)){
                
                streak += 1
            }
            else{
                streak = 1
            }
            
            lastDate = date
            
            if streak > maxStreak {
                maxStreak = streak
            }
        }
        
        return String(maxStreak)
    }

    func overallTrainingNumber() -> String {
        
        return String(records.count)
    }
    
    func overallTrainingTime() -> String {
        
        let times = records.compactMap({ $0.time})
        
        let sum = times.reduce(0, +)

        return Time().getTimeFromSeconds(Int(sum), minretval: "minutes")
    }
    
    func favouriteSportInfo() -> (String, String, String) {
            
        var activitySums: [Int: Int] = [:]
        
        for record in records {
            let value = activitySums[Int(record.sport)] ?? 0
            activitySums[Int(record.sport)] = value + Int(record.time)
        }
        
        var maxTime = 0
        var maxSport = 0
        for activity in activitySums {
            if activity.value > maxTime {
                maxTime = activity.value
                maxSport = activity.key
            }
        }
            
        let sport = SportType.sportsArray[maxSport].idName ?? ""
        
        let _records = records.compactMap({ $0.sport})
        var trainings = 0
        for sport in _records {
            if sport == maxSport {
                trainings += 1
            }
        }
            
        let stringMaxTime = Time().getTimeFromSeconds(Int(maxTime), minretval: "minutes")
        
        return (String(sport), String(trainings), stringMaxTime)
    }
    
}
