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
class TrackerRecordCoreData: NSManagedObject {
    @nonobjc class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }
    
    @NSManaged var id: String
    @NSManaged var date: Date
    @NSManaged var tracker: TrackerCoreData
}
