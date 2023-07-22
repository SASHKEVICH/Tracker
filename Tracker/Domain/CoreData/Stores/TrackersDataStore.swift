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

	func tracker(with id: String) -> TrackerCoreData? {
		let request = TrackerCoreData.fetchRequest()
		request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.id), id)
		return try? self.context.fetch(request).first
	}

    func add(tracker: TrackerCoreData, in category: TrackerCategoryCoreData) throws {
		tracker.category = category
        category.addToTrackers(tracker)
		try self.context.save()
    }

	func delete(tracker: Tracker) {
		guard let trackerCoreData = self.tracker(with: tracker.id.uuidString) else { return }
		self.delete(trackerCoreData: trackerCoreData)
	}

	func delete(trackerCoreData: TrackerCoreData) {
		let categoryRequest = TrackerCategoryCoreData.fetchRequest()
		categoryRequest.predicate = NSPredicate(
			format: "%K == %@", #keyPath(TrackerCategoryCoreData.id), trackerCoreData.category.id
		)
		guard let category = try? self.context.fetch(categoryRequest).first else { return }

		category.removeFromTrackers(trackerCoreData)

		do {
			self.context.delete(trackerCoreData)
			try self.context.save()
		} catch {
			print(error)
		}
	}

	func pin(tracker: TrackerCoreData, pinnedCategory: TrackerCategoryCoreData) {
		let trackerWithRecords = self.trackerWithRecords(convert: tracker)

		trackerWithRecords.category = pinnedCategory
		pinnedCategory.addToTrackers(trackerWithRecords)

		do {
			self.delete(trackerCoreData: tracker)
			try self.context.save()
		} catch {
			assertionFailure(error.localizedDescription)
			return
		}
	}

	func unpin(tracker: TrackerCoreData, previousCategory: TrackerCategoryCoreData) {
		let trackerWithRecords = self.trackerWithRecords(convert: tracker)

		trackerWithRecords.category = previousCategory
		previousCategory.addToTrackers(trackerWithRecords)

		do {
			self.delete(trackerCoreData: tracker)
			try self.context.save()
		} catch {
			assertionFailure(error.localizedDescription)
			return
		}
	}
}

private extension TrackersDataStore {
	func trackerWithRecords(convert tracker: TrackerCoreData) -> TrackerCoreData {
		let trackerWithRecords = TrackerCoreData(context: self.context)
		trackerWithRecords.id = tracker.id
		trackerWithRecords.title = tracker.title
		trackerWithRecords.records = tracker.records
		trackerWithRecords.colorHex = tracker.colorHex
		trackerWithRecords.emoji = tracker.emoji
		trackerWithRecords.isPinned = tracker.isPinned
		trackerWithRecords.previousCategoryId = tracker.previousCategoryId
		trackerWithRecords.weekDays = tracker.weekDays
		trackerWithRecords.type = tracker.type
		return trackerWithRecords
	}
}
