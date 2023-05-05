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
class TrackerCoreData: NSManagedObject {
    @NSManaged var colorHex: String
    @NSManaged var emoji: String
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var type: Int16
    @NSManaged var weekDays: String
    @NSManaged var category: TrackerCategoryCoreData
    @NSManaged var records: NSSet
}

// MARK: Generated accessors for records
extension TrackerCoreData {
    @objc(addRecordsObject:)
    @NSManaged func addToRecords(_ value: TrackerRecordCoreData)

    @objc(removeRecordsObject:)
    @NSManaged func removeFromRecords(_ value: TrackerRecordCoreData)

    @objc(addRecords:)
    @NSManaged func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged func removeFromRecords(_ values: NSSet)
}
