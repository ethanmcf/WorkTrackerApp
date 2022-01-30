//
//  Job+CoreDataProperties.swift
//  WorkTrackerApp
//
//  Created by Ethan McFarland on 2021-11-12.
//
//

import Foundation
import CoreData


extension Job {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Job> {
        return NSFetchRequest<Job>(entityName: "Job")
    }

    @NSManaged public var name: String?
    @NSManaged public var hoursWorked: Float
    @NSManaged public var hoursPaid: Float
    @NSManaged public var payRate: Float
    @NSManaged public var shifts: NSSet?

}

// MARK: Generated accessors for shifts
extension Job {

    @objc(addShiftsObject:)
    @NSManaged public func addToShifts(_ value: Shift)

    @objc(removeShiftsObject:)
    @NSManaged public func removeFromShifts(_ value: Shift)

    @objc(addShifts:)
    @NSManaged public func addToShifts(_ values: NSSet)

    @objc(removeShifts:)
    @NSManaged public func removeFromShifts(_ values: NSSet)

}

extension Job : Identifiable {

}
