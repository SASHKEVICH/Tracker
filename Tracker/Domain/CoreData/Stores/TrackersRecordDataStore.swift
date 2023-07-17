//
//  TrackersRecordDataStore.swift
//  Tracker
//
//  Created by Александр Бекренев on 29.04.2023.
//

import Foundation
import CoreData

struct TrackersRecordDataStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackersRecordDataStore {
    var managedObjectContext: NSManagedObjectContext {
		self.context
    }
    
	func complete(tracker: TrackerCoreData, date: Date) throws {
        guard let date = date.withoutTime else { return }
        let record = TrackerRecordCoreData(context: context)
		record.id = tracker.id
        record.date = date

		tracker.addToRecords(record)
		try self.context.save()
    }
    
	func incomplete(tracker: TrackerCoreData, record: TrackerRecordCoreData) throws {
		self.context.delete(record)
		tracker.removeFromRecords(record)
		try self.context.save()
    }

	func addRecords(for trackerId: String, amount: Int) {
		let request = TrackerCoreData.fetchRequest()
		let predicate = NSPredicate(
			format: "%K == %@",
			#keyPath(TrackerCoreData.id), trackerId)
		request.predicate = predicate

		guard let tracker = try? self.context.fetch(request).first else { return }
		for _ in 0..<amount {
			let record = TrackerRecordCoreData(context: self.context)
			record.id = trackerId
			record.date = Date()
			tracker.addToRecords(record)
		}

		try? self.context.save()
	}

	func removeRecords(for trackerId: String, amount: Int) {
		let request = TrackerRecordCoreData.fetchRequest()
		let predicate = NSPredicate(
			format: "%K == %@",
			#keyPath(TrackerRecordCoreData.id), trackerId)
		request.predicate = predicate

		guard let records = try? self.context.fetch(request) else { return }
		for i in 0..<amount {
			self.context.delete(records[i])
		}

		try? self.context.save()
	}

	func completedTrackersCount() -> Int? {
		let request = TrackerRecordCoreData.fetchRequest()
		do {
			let object = try self.context.fetch(request)
			return object.count
		} catch {
			return nil
		}
	}
    
    func completedTimesCount(trackerId: String) -> Int? {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordCoreData.id), trackerId)
        request.predicate = predicate

		do {
			let object = try self.context.fetch(request)
			return object.count
		} catch {
			return nil
		}
    }
    
	func completedTrackers(for date: Date) -> [TrackerRecordCoreData] {
		let request = TrackerRecordCoreData.fetchRequest()
		let predicate = NSPredicate(
			format: "%K == %@",
			#keyPath(TrackerRecordCoreData.date), date as NSDate)
		request.predicate = predicate

		let records = try? context.fetch(request)
		return records ?? []
	}
    
    func record(with id: String, date: NSDate) -> TrackerRecordCoreData? {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.id), id,
            #keyPath(TrackerRecordCoreData.date), date)
        request.predicate = predicate
        request.fetchLimit = 1
        
        let records = try? context.fetch(request)
        return records?.first
    }
}
