//
//  SportType.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 18/02/2021.
//

import Foundation
import UIKit


/// Structure representing sport information
struct SportTypeStruct {
    var idNumber: Int!
    var idName: String!
    var image: UIImage!
}

/// Structure handling all sports and their parameters
struct SportType {
    
    /// Constant reachable anywhere in the code representing different sports
    /// In case of adding a new sport, it is enough to add it here
    static let sportsArray: [SportTypeStruct] = [
        SportTypeStruct(idNumber: 0, idName: "All sports", image: UIImage(named: "allsports")?.withRenderingMode(.alwaysOriginal)),
        SportTypeStruct(idNumber: 1, idName: "Bicycle", image: UIImage(named: "bicycle_gold")?.withRenderingMode(.alwaysOriginal)),
        SportTypeStruct(idNumber: 2, idName: "Unicycle", image: UIImage(named: "unicycle_gold")?.withRenderingMode(.alwaysOriginal)),
        SportTypeStruct(idNumber: 3, idName: "Skateboard", image: UIImage(named: "skateboard_gold")?.withRenderingMode(.alwaysOriginal)),
        SportTypeStruct(idNumber: 4, idName: "Swimming", image: UIImage(named: "swimming_gold")?.withRenderingMode(.alwaysOriginal)),
        SportTypeStruct(idNumber: 5, idName: "Tennis", image: UIImage(named: "tennis_gold")?.withRenderingMode(.alwaysOriginal)),
        SportTypeStruct(idNumber: 6, idName: "Badminton", image: UIImage(named: "badminton_gold")?.withRenderingMode(.alwaysOriginal)),
        SportTypeStruct(idNumber: 7, idName: "Workout", image: UIImage(named: "workout_gold")?.withRenderingMode(.alwaysOriginal)),
        SportTypeStruct(idNumber: 8, idName: "Dancing", image: UIImage(named: "dancing_gold")?.withRenderingMode(.alwaysOriginal)),
        SportTypeStruct(idNumber: 9, idName: "Kayak", image: UIImage(named: "kayak")?.withRenderingMode(.alwaysOriginal)),
        SportTypeStruct(idNumber: 10, idName: "Football", image: UIImage(named: "football")?.withRenderingMode(.alwaysOriginal)),
        SportTypeStruct(idNumber: 11, idName: "Yoga", image: UIImage(named: "yoga")?.withRenderingMode(.alwaysOriginal)),
        SportTypeStruct(idNumber: 12, idName: "Hiking", image: UIImage(named: "hiking")?.withRenderingMode(.alwaysOriginal)),
        SportTypeStruct(idNumber: 13, idName: "Running", image: UIImage(named: "running")?.withRenderingMode(.alwaysOriginal)),
        SportTypeStruct(idNumber: 14, idName: "Archery", image: UIImage(named: "archery")?.withRenderingMode(.alwaysOriginal))
//        SportTypeStruct(idNumber: 7, idName: "Yoga", image: UIImage(systemName: "bicycle.circle"))
    ]
    
}
