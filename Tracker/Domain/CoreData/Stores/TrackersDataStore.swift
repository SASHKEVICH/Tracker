//
//  TrackersDataStore.swift
//  Tracker
//
//  Created by Александр Бекренев on 29.04.2023.
//

import Foundation
import CoreData

struct TrackersDataStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackersDataStore {
    var managedObjectContext: NSManagedObjectContext {
		self.context
    }
    
    func add(tracker: TrackerCoreData, in category: TrackerCategoryCoreData) throws {
        category.addToTrackers(tracker)
		try self.context.save()
    }

	func delete(tracker: Tracker) {
		let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
		request.predicate = NSPredicate(format: "%K==%@", #keyPath(TrackerCoreData.id), tracker.id.uuidString)
		do {
			guard let object = try self.context.fetch(request).first else { return }
			self.context.delete(object)
			try self.context.save()
		} catch {
			print(error)
		}
	}
}
