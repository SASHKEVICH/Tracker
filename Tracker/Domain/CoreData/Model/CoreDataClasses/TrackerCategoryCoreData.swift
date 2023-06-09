//
//  TrackerCategoryCoreData.swift
//  Tracker
//
//  Created by Александр Бекренев on 30.04.2023.
//
//

import Foundation
import CoreData

@objc(TrackerCategoryCoreData)
class TrackerCategoryCoreData: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var trackers: NSSet
}

// MARK: Generated accessors for trackers
extension TrackerCategoryCoreData {
    @objc(addTrackersObject:)
    @NSManaged func addToTrackers(_ value: TrackerCoreData)

    @objc(removeTrackersObject:)
    @NSManaged func removeFromTrackers(_ value: TrackerCoreData)

    @objc(addTrackers:)
    @NSManaged func addToTrackers(_ values: NSSet)

    @objc(removeTrackers:)
    @NSManaged func removeFromTrackers(_ values: NSSet)
    
    func trackers(for weekDay: String) -> [TrackerCoreData] {
        let predicate = NSPredicate(format: "weekDays CONTAINS[c] %@", weekDay)
        return Array(trackers.filtered(using: predicate)) as! [TrackerCoreData]
    }
}
