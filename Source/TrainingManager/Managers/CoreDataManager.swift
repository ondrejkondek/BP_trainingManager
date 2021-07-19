//
//  CoreDataManager.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 03/03/2021.
//

import Foundation
import CoreData

/// Class handling all the processes with Core Data
class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let context: NSManagedObjectContext!
    let container: NSPersistentContainer!
    let backContext: NSManagedObjectContext!
    
    init() {
        self.context = getMOC()
        self.container = getPersistentContainer()
        self.backContext = container.newBackgroundContext()
    }
    
    /// Saving method
    /// - Returns: 0 if succesful else 1
    func saveData() -> Int{
        do{
            try self.context.save()
            return 0
        }catch{
            print("saving failed!")
            return 1
        }
    }
  
    /// Fetches the user settings  of a user - locally
    /// - Returns: UserSettings or nil
    func fetchUserSettings() -> UserSettings? {
        
        var items: [UserSettings]?
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserSettings")
        request.predicate = NSPredicate(value: true)
        request.returnsObjectsAsFaults = false

        do{
            items = try self.context.fetch(request) as? [UserSettings]
        }
        catch{
            print("Problem while fetching records")
        }
        
        return items?.first ?? nil
        
    }
    
    /// Fetches the records
    /// - Parameter predicate: predicate for fetch
    /// - Returns: Array of found records or nil
    func fetchRecords(predicate: NSPredicate) -> [Record]? {

        var items: [Record]?
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        request.predicate = predicate
        request.returnsObjectsAsFaults = false

        do{
            items = try self.context.fetch(request) as? [Record]
        }
        catch{
            print("Problem while fetching records")
        }
        
        return items ?? nil
    }
    
    /// Fetches the records in background
    /// Use for collecting data for public statistics
    /// - Parameter predicate: predicate for fetch
    /// - Parameter completion: escaping completion containing array of records from fetch
    func fetchRecordsInBackground(predicate: NSPredicate, completion: @escaping (([Record]?) -> Void)) {
        
        self.backContext.perform {

            var items: [Record]?
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")

            request.predicate = predicate
            request.returnsObjectsAsFaults = false

            do{
                items = try self.backContext.fetch(request) as? [Record]
            }
            catch{
                print("Problem while fetching records")
            }
            
            completion(items ?? nil)
        }
    }
    
    /// Fetches the records for the specific day
    /// - Parameter sport: ID of the sport to be fetched
    /// - Parameter date: Date in fetch
    /// - Returns: Array of found records or nil
    func fetchRecordsForDay(sport: Int, date: Date) -> [Record]? {
        
        var dayRecords: [Record]?
        let startDay = date.getDayTimes(start: true, date: date)
        let endDay = date.getDayTimes(start: false, date: date)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        
        if (sport != 0){
            request.predicate = NSPredicate(format: "sport = %d AND date <= %@ AND date >= %@", sport, endDay as NSDate, startDay as NSDate)
        }
        else{
            request.predicate = NSPredicate(format: "date <= %@ AND date >= %@", endDay as NSDate, startDay as NSDate)
        }

        request.returnsObjectsAsFaults = false
        
        do{
            dayRecords = try self.context.fetch(request) as? [Record]
        }
        catch{
            print("Problem while fetching records")
        }
        
        return dayRecords ?? nil
    }

    /// Method deletes all the records of all sports
    func deleteAllRecords()
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        let batchData = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try self.context.execute(batchData)
        }
        catch {
            print("Unable to delete all data")
        }
    }
}
