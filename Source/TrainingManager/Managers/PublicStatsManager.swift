//
//  PublicStatsManager.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 10/05/2021.
//

import Foundation

/// Getting Metadata out of Records
/// Use for public statistics
class PublicStatsManager {
    
    /// Get User Statistics from last week
    /// - Returns: ID of favourite sport, Time of Favourite sport, and Time trained of all sports
    func getUserStats() -> (Int, Int, Int) {
        
        // Dispatch group to handle async processes
        let group = DispatchGroup()
        group.enter()
        
        var favSport = 0
        var timeOfFavSport = 0
        var timeOfAllSports = 0
        let predicate = NSPredicate(format: "date <= %@ AND date >= %@", Date() as NSDate, Date().getXdaysAgoDate(daysAgo: 7) as NSDate)
        
        CoreDataManager.shared.fetchRecordsInBackground(predicate: predicate) { records in
            
            guard let records = records else{
                group.leave()
                return
            }

            let favSportInfo = self.getFavSport(records: records)
            favSport = favSportInfo.0
            timeOfFavSport = favSportInfo.1
            timeOfAllSports = self.getOveralTime(records: records)
            group.leave()
        }

        group.wait()
        return (favSport, timeOfFavSport, timeOfAllSports)
    }
    
    /// Finds a favourite sport
    /// Sport that was mostly trained
    /// - Parameter records: array of records to be searched in
    /// - Returns: tupple of ID sport and its time
    func getFavSport(records: [Record]) -> (Int, Int) {
        
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
        
        return (maxSport, maxTime)
    }
    
    /// Gets the overall time of all sports
    /// - Parameter records: array of records to be searched in
    /// - Returns: time of all sports
    func getOveralTime(records: [Record]) -> Int {
        
        var sum = 0
        for record in records {
            sum = sum + Int(record.time)
        }
        
        return sum
    }
}
