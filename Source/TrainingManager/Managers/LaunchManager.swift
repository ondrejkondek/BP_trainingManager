//
//  LaunchManager.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 14/03/2021.
//

import UIKit
import CloudKit

/// Manager to handle actions when App is launched
///
///  - Create, Load an account - authorization
///  - Update data on background
class LaunchManager {
    
    static let shared = LaunchManager()
    
    let backContext = CoreDataManager.shared.backContext
    
    /// Create settings and account for a completely new user
    func firstLaunchCreateSettings() {

        // getting permission for getting iCloud data (name, surname)
        CKContainer.init(identifier: "iCloud.TrainingManager").requestApplicationPermission(.userDiscoverability) { (status, error) in

            if status == .denied {
                // Create new user settings
                let settings = UserSettings(context: self.backContext!)
                settings.id = UUID().uuidString
                settings.name = String("Name")
                settings.surname = String("Surname")
                
                UserDefaultsManager.shared.ud.setValue(settings.id, forKey: "id")
                UserDefaultsManager.shared.ud.setValue(settings.name, forKey: "name")
                UserDefaultsManager.shared.ud.setValue(settings.surname, forKey: "surname")
                
                do{
                    try self.backContext!.save() // save into backContext CoreData
                }catch{
                    print("saving failed!")
                }
                return
            }
            
            // getting iCloud data
            CKContainer.init(identifier: "iCloud.TrainingManager").fetchUserRecordID { (record, error) in

                if let record = record {

                    // getting iCloud User data
                    CKContainer.init(identifier: "iCloud.TrainingManager").discoverUserIdentity(withUserRecordID: record, completionHandler: {
                        (userID, error) in

                        if let userID = userID{
              
                            // Create new user settings according to iCloud info
                            let settings = UserSettings(context: self.backContext!)
                            settings.id = UUID().uuidString
                            settings.name = String(userID.nameComponents?.givenName ?? "Name")
                            settings.surname = String(userID.nameComponents?.familyName ?? "Surname")
                            
                            UserDefaultsManager.shared.ud.setValue(settings.id, forKey: "id")
                            UserDefaultsManager.shared.ud.setValue(settings.name, forKey: "name")
                            UserDefaultsManager.shared.ud.setValue(settings.surname, forKey: "surname")
                            
                            do{
                                try self.backContext!.save() // save into backContext CoreData
                            }catch{
                                print("saving failed!")
                            }
                            return
                        }
                        // Info about the user could not be reached
                        else{
                            self.defaultSettingsInCaseOfError()
                            print(error as Any)
                        }
                    })
                }
                // Info about the user could not be reached
                else{
                    self.defaultSettingsInCaseOfError()
                    return
                }
                
            }
        }
    }
    
    /// Method to setup app when it is first launched
    /// If there is iCloud  available and it is not
    func firstLaunchSetAccount() {
        
        if CloudKitManager.shared.isiCloudAvailable() {
            // Try to fetch UserSettings
            CloudKitManager.shared.fetchUserSettings() {
                settings in
                
                // load an existing account
                if !settings.isEmpty {
                    let id = settings.first?.value(forKey: "CD_id") as? String
                    UserDefaultsManager.shared.ud.setValue(id, forKey: "id")
                    let name = settings.first?.value(forKey: "CD_name") as? String
                    UserDefaultsManager.shared.ud.setValue(name, forKey: "name")
                    let surname = settings.first?.value(forKey: "CD_surname") as? String
                    UserDefaultsManager.shared.ud.setValue(surname, forKey: "surname")
                    return
                }

                // Create New UserSettings
                else {
                    self.firstLaunchCreateSettings()
                    return
                }
            }
            
        }
        else {
            // First Launch not succesful, try next time - lack of Internet Connection
            defaultSettingsInCaseOfError()
        }
    }
    
    /// Setting in case of error or unavailable iCloud / internet connection
    func defaultSettingsInCaseOfError(){
        UserDefaultsManager.shared.ud.setValue(true, forKey: "firstLaunch")
        UserDefaultsManager.shared.ud.setValue("xxx", forKey: "id")
        UserDefaultsManager.shared.ud.setValue("Name", forKey: "name")
        UserDefaultsManager.shared.ud.setValue("Surname", forKey: "surname")
    }
    
    /// Updating public stats once a day
    func updatePublicStats() {

        // Control if public stats for the user
        let lastUpdate = UserDefaultsManager.shared.getLastUpdatePublicStats()
        
        // last update exists
        if let lastUpdate = lastUpdate {
            
            if lastUpdate.isToday() {
                print("Everything is updated")
            }
            else {
                makePublicStats()
            }
        }
        // if last update == nil, first launch of the App
        else{
            makePublicStats()
        }
    }
    
    /// Update or create public stats of the user
    /// If no connction - nothing happens
    func makePublicStats() {
        // update UserStats globally
        
        if CloudKitManager.shared.isiCloudAvailable() {
                    
            UserDefaultsManager.shared.setLastUpdatePublicStats()
            
            let id = UserDefaultsManager.shared.ud.value(forKey: "id") as? String
            let name = UserDefaultsManager.shared.ud.value(forKey: "name") as? String
            let surname = UserDefaultsManager.shared.ud.value(forKey: "surname") as? String
            
            // this is on back thread
            CloudKitManager.shared.fetchUserStats(predicate: NSPredicate(format: "id = %@", id ?? "")) { records in
                if records.isEmpty{
                    CloudKitManager.shared.createUserStats(id: id ?? "", name: name ?? "", surname: surname ?? "")
                }
                else{
                    let userStats = records.first
                    CloudKitManager.shared.updateUserStats(record: userStats!, id: id ?? "", name: name ?? "", surname: surname ?? "")
                }
            }
        }
        // No Internet connection
        else{
            return
        }
    }
    
}
