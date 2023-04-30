//
//  TrackerCoreData.swift
//  Tracker
//
//  Created by Александр Бекренев on 30.04.2023.
//
//

import Foundation
import CoreData

@objc(TrackerCoreData)
public class TrackerCoreData: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var colorHex: String
    @NSManaged public var emoji: String
    @NSManaged public var type: Int16
    @NSManaged public var weekDays: Data?
    @NSManaged public var records: NSSet
    @NSManaged public var category: TrackerCategoryCoreData
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
