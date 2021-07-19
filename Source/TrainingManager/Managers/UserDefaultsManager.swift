//
//  UserDefaultsManager.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 18/02/2021.
//

import Foundation

/// Class handling all the processes with UserDefaults
class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    /// ud belongs to main application (unable to access from widget)
    let ud = UserDefaults(suiteName: "ondrejkondek.TrainingManager.userDefaults")!
    
    /// udShared is shared between widget extension and main application
    let udShared = UserDefaults(suiteName: "group.ondrejkondek.WidgetDemo")!
    
    /// - Returns: ID of an actual sport
    func getActualSport() -> Int {
        
        if let value = self.ud.value(forKey: "actualSport") as? Int {
            return value
        }
        
        return 0
    }
    
    /// Method sets and stores an actual sport
    /// - Parameter sport: ID of the sport
    func setActualSport(_ sport: Int) {
        self.ud.setValue(sport, forKey: "actualSport")
    }
    
    /// First launch of the app handler - Locally
    /// - Returns: True if first launch else False
    func isFirstLaunch() -> Bool {

        if let value = self.ud.value(forKey: "firstLaunch") as? Bool {
            if value == true {
                self.ud.setValue(false, forKey: "firstLaunch")
            }
            
            return value
        }
        else {
            self.ud.setValue(false, forKey: "firstLaunch")
            // Init actual sport
            self.ud.setValue(0, forKey: "actualSport")
            return true
        }
    }
    
    /// Public stats that are sent once a day
    /// - Returns: date of last update
    func getLastUpdatePublicStats() -> Date? {
        
        if let value = self.ud.value(forKey: "lastUpdatePublicStats") as? Date {
            return value
        }
        else {
            return nil
        }
    }
    
    /// Sets Public stats update to today
    func setLastUpdatePublicStats() {
        
        self.ud.setValue(Date(), forKey: "lastUpdatePublicStats")
    }
    
    /// Siri voiceshortcut handler - getter
    /// - Parameter key: key of the userdefaults
    /// - Returns: UUID of the voiceshortcut or nil
    func getSiriVoiceShortcut(key: String) -> UUID? {
        
        let decoded = self.ud.object(forKey: key) as? Data
        let uuid = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded ?? Data()) as? UUID
        
        if let uuid = uuid{
            return uuid
        }
        
        return nil
    }
    
    /// Siri voiceshortcut handler - setter
    /// - Parameter key: key of the userdefaults
    /// - Parameter UUID: UUID to be stored
    func setSiriVoiceShortcut(key: String, uuid: UUID) {
        
        let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: uuid, requiringSecureCoding: false)
            
        if let encodedData = encodedData{
            self.ud.set(encodedData, forKey: key)
        }
    }
    
    /// Siri voiceshortcut handler
    /// Deletes wanted voiceshortcut ID from Userdefaults
    /// - Parameter key: key of the userdefaults
    /// - Parameter UUID: UUID to be deleted
    func removeSiriVoiceShortcut(key: String, uuid: UUID) {
          
        let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: uuid, requiringSecureCoding: false)
            
        if encodedData != nil{
            self.ud.removeObject(forKey: key)
        }
    }

    /// Method storing info for widget to be shown
    /// - Parameter sport: sport to be shown
    /// - Parameter running: true if training is running
    /// - Parameter reset: true if training was reseted
    /// - Parameter setTime: time when the training started
    func widgetTrainingInfo(sport: Int, running: Bool, reset: Bool, setTime: Bool) {
        
        self.udShared.setValue(sport, forKey: "actualSport")
        self.udShared.setValue(running, forKey: "runningTraining")
        self.udShared.setValue(reset, forKey: "resetZero")
        if setTime{
            self.udShared.setValue(Date(), forKey: "startTime")
        }
    }
    
    /// Getter of all stored info for widget:
    /// sport, running, reset, time
    /// - Returns: Tupple of (sport, running, reset, time)
    func getWidgetTrainingInfo() -> (Int?, Bool?, Bool?, Date?){
        
        let sport = self.udShared.value(forKey: "actualSport") as? Int
        let running = self.udShared.value(forKey: "runningTraining") as? Bool
        let reset = self.udShared.value(forKey: "resetZero") as? Bool
        let time = self.udShared.value(forKey: "startTime") as? Date
        
        return (sport, running, reset, time)
    }
    
    /// Getter of actual streak
    /// How many days in a row user used the app
    /// - Returns: day of last update, number of streak days
    func getStreak() -> (Date, Int) {
        
        var date: Date?
        if let _date = self.ud.value(forKey: "streakDate") as? Date {
            date = _date
        }
        else {
            self.ud.setValue(Date(), forKey: "streakDate")
            date = Date()
        }
        
        var number: Int?
        if let _num = self.ud.value(forKey: "streakNumber") as? Int {
            number = _num
        }
        else {
            self.ud.setValue(1, forKey: "streakNumber")
            number = 1
        }
        
        return(date!, number!)
    }
    
    /// Method controlling the streak
    /// - Returns: Number of days in a row - actual number from today
    func controlStreak() -> Int {
        
        let streak = getStreak()
        let date = streak.0
        let number = streak.1
        
        if date.isToday(){
            return number
        }
        
        let yesterday = date.getXdaysAgoDate(daysAgo: 2)
        let yesterdayComponents = Calendar.current.dateComponents([.year, .day, .month], from: yesterday)
        let dateComponents = Calendar.current.dateComponents([.year, .day, .month], from: date)
        
        if ((yesterdayComponents.year == dateComponents.year) &&
            (yesterdayComponents.month == dateComponents.month) &&
                (yesterdayComponents.day == dateComponents.day)){
            
            self.ud.setValue(Date(), forKey: "streakDate")
            self.ud.setValue(number+1, forKey: "streakNumber")
            let _ = bestStreak(streak: number+1)
            
            return number+1
        }
        else{
            self.ud.setValue(Date(), forKey: "streakDate")
            self.ud.setValue(1, forKey: "streakNumber")
            
            return 1
        }
    }
    
    /// Stores the best streak ever
    /// - Parameter streak: actual streak
    /// - Returns: number of best streak ever counted
    func bestStreak(streak: Int) -> Int {
        
        var bestStreak: Int?
        if let _best = self.ud.value(forKey: "bestStreak") as? Int {
            bestStreak = _best
        }
        else {
            self.ud.setValue(1, forKey: "bestStreak")
            bestStreak = 1
        }
        
        if streak > bestStreak! {
            self.ud.setValue(streak, forKey: "bestStreak")
        }
        
        return bestStreak ?? 1
    }
    
}
