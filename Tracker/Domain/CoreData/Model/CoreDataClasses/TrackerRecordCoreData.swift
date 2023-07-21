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
final class TrackerRecordCoreData: NSManagedObject {
	static let entityName = String(describing: TrackerRecordCoreData.self)

    @nonobjc class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
		NSFetchRequest<TrackerRecordCoreData>(entityName: TrackerRecordCoreData.entityName)
    }
    
    @NSManaged var id: String
    @NSManaged var date: Date
    @NSManaged var tracker: TrackerCoreData
}
