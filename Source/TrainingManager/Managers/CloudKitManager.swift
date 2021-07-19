//
//  CloudKitManager.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 03/03/2021.
//

import Foundation
import CloudKit

/// Class - singleton managing all the CloudKit processes
class CloudKitManager {
    
    static let shared = CloudKitManager()
    
    /// public iCloud database
    private let DB = CKContainer(identifier: "iCloud.TrainingManager").publicCloudDatabase
    
    /// private iCloud database
    private let DBprivate = CKContainer(identifier: "iCloud.TrainingManager").privateCloudDatabase

    /// Update existing User stats record in iCloud
    /// - Parameter record: existing record to be updated
    /// - Parameter id: id of the user
    /// - Parameter name: name of the user
    /// - Parameter surname: surname of the user
    func updateUserStats(record: CKRecord, id: String, name: String, surname: String) {
        
        let sportsInfo = PublicStatsManager().getUserStats()
        
        record.setValue(id, forKey: "id")
        record.setValue(name, forKey: "name")
        record.setValue(surname, forKey: "surname")
        record.setValue(sportsInfo.0, forKey: "favSport")
        record.setValue(sportsInfo.1, forKey: "timeOfFavSport")
        record.setValue(sportsInfo.2, forKey: "timeOfAllSports")
        record.setValue(Date(), forKey: "lastUpdate")
        
        saveCKRecord(record: record)
    }
    
    /// Create a new User stats record in iCloud
    /// - Parameter id: id of the user
    /// - Parameter name: name of the user
    /// - Parameter surname: surname of the user
    func createUserStats(id: String, name: String, surname: String) {
        
        let sportsInfo = PublicStatsManager().getUserStats()
        let record = CKRecord(recordType: "UserStats")
        
        record.setValue(id, forKey: "id")
        record.setValue(name, forKey: "name")
        record.setValue(surname, forKey: "surname")
        record.setValue(sportsInfo.0, forKey: "favSport")
        record.setValue(sportsInfo.1, forKey: "timeOfFavSport")
        record.setValue(sportsInfo.2, forKey: "timeOfAllSports")
        record.setValue(Date(), forKey: "lastUpdate")
    
        saveCKRecord(record: record)
    }
    
    /// Saving method for CloudKit
    func saveCKRecord(record: CKRecord){
        
        DB.save(record) { record, error in
            if error == nil {
                print("saved")
            }
            else{
                print("Unable to save to iCloud")
                // Not needed to inform user
                // everything works in background
            }
        }
    }
    
    /// Fetching all userStats existing in public database
    /// - Parameter predicate: predicate for fetch
    /// - Parameter completion: escaping completion containing array of records from fetch
    func fetchUserStats(predicate: NSPredicate, completion: @escaping (([CKRecord]) -> Void)){
        
        let query: CKQuery!
        query = CKQuery(recordType: "UserStats", predicate: predicate)
        
        DB.perform(query, inZoneWith: nil, completionHandler: { records, error in
            if let records = records, error == nil {
                completion(records)
            }
            else{
                completion([])
            }
        })
    }
    
    /// Fetching UserSettings of the user - CoreData record
    /// Use for authentification because sync of CoreData via iCloud is not guaranteed
    /// - Parameter completion: escaping completion containing array of records from fetch
    func fetchUserSettings(completion: @escaping (([CKRecord]) -> Void)){
        
        let query: CKQuery!
        query = CKQuery(recordType: "CD_UserSettings", predicate: NSPredicate(value: true))

        DBprivate.perform(query, inZoneWith: nil, completionHandler: { records, error in
            
            if let records = records, error == nil {

                completion(records)
            }
            else{
                print(error ?? "Error")
                completion([])
            }
        })
    }
    
    /// Finds out if iCloud is available
    /// - Returns: True if available else False
    func isiCloudAvailable() -> Bool {
        
        if FileManager.default.ubiquityIdentityToken != nil {
            return true
        }
        else {
            return false
        }
    }
    
}
