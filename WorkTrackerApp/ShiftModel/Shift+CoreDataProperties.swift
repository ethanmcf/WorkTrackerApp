//
//  Shift+CoreDataProperties.swift
//  WorkTrackerApp
//
//  Created by Ethan McFarland on 2021-11-12.
//
//

import Foundation
import CoreData


extension Shift {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Shift> {
        return NSFetchRequest<Shift>(entityName: "Shift")
    }

    @NSManaged public var length: Float
    @NSManaged public var time: String?
    @NSManaged public var payed: Bool
    @NSManaged public var month: String?
    @NSManaged public var day: String?
    @NSManaged public var year: String?
    @NSManaged public var job: Job?

}

extension Shift : Identifiable {

}
