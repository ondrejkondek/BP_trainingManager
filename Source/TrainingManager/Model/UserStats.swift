//
//  UserStats.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 03/03/2021.
//

import Foundation

/// Structure representing statistics sent to iCloud as CKRecord 
struct UserStats {
    
    var id: String?
    var name: String?
    var surname: String?
    var favSport: Int?
    var timeOfFavSport: Int?
    var timeOfAllSports: Int?
    var lastUpdate: Date?
    
    /// Create userInfo out of given information
    /// - Parameters: Needed info about the record - favSport, timeOfFavSport, timeOfAllSports lastUpdate name
    /// - Returns: UserStats object 
    func setUserInfo(favSport: Int, timeOfFavSport: Int, timeOfAllSports: Int, lastUpdate: Date, name: String) -> UserStats{
        var user = UserStats()
        user.favSport = favSport
        user.timeOfFavSport = timeOfFavSport
        user.timeOfAllSports = timeOfAllSports
        user.lastUpdate = lastUpdate
        user.name = name
        return user
    }

}
