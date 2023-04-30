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
public class TrackerCategoryCoreData: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var trackers: NSSet
}

// MARK: Generated accessors for trackers
extension TrackerCategoryCoreData {
    @objc(addTrackersObject:)
    @NSManaged public func addToTrackers(_ value: TrackerCoreData)

    @objc(removeTrackersObject:)
    @NSManaged public func removeFromTrackers(_ value: TrackerCoreData)

    @objc(addTrackers:)
    @NSManaged public func addToTrackers(_ values: NSSet)

    @objc(removeTrackers:)
    @NSManaged public func removeFromTrackers(_ values: NSSet)
}
