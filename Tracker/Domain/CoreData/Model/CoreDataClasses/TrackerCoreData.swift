//
//  TrackerCoreData.swift
//  Tracker
//
//  Created by Александр Бекренев on 01.05.2023.
//
//

import Foundation
import CoreData

@objc(TrackerCoreData)
public class TrackerCoreData: NSManagedObject {
    @NSManaged public var colorHex: String
    @NSManaged public var emoji: String
    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var type: Int16
    @NSManaged public var weekDays: String
    @NSManaged public var category: TrackerCategoryCoreData
    @NSManaged public var records: NSSet
}

// MARK: Generated accessors for records
extension TrackerCoreData {
    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: TrackerRecordCoreData)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: TrackerRecordCoreData)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)
}
