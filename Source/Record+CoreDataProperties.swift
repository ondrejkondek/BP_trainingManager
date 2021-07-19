//
//  Record+CoreDataProperties.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 04/03/2021.
//
//

import Foundation
import CoreData


extension Record {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record")
    }

    @NSManaged public var date: Date?
    @NSManaged public var location: String?
    @NSManaged public var notes: String?
    @NSManaged public var sport: Int16
    @NSManaged public var time: Int32

}

extension Record : Identifiable {

}
