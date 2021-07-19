//
//  UserSettings+CoreDataProperties.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 04/03/2021.
//
//

import Foundation
import CoreData


extension UserSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserSettings> {
        return NSFetchRequest<UserSettings>(entityName: "UserSettings")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var privateSession: Bool
    @NSManaged public var surname: String?

}

extension UserSettings : Identifiable {

}
