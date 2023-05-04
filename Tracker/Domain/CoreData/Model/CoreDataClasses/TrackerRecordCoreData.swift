//
//  TrackerRecordCoreData.swift
//  Tracker
//
//  Created by Александр Бекренев on 30.04.2023.
//
//

import Foundation
import CoreData

@objc(TrackerRecordCoreData)
public class TrackerRecordCoreData: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }
    
    @NSManaged public var id: String
    @NSManaged public var date: Date
    @NSManaged public var tracker: TrackerCoreData
}
