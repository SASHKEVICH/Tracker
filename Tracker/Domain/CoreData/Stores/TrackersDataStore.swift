//
//  TrackersDataStore.swift
//  Tracker
//
//  Created by Александр Бекренев on 29.04.2023.
//

import CoreData
import Foundation

struct TrackersDataStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackersDataStore {
    var managedObjectContext: NSManagedObjectContext {
        context
    }

    func tracker(with id: String) -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.id), id)
        return try? context.fetch(request).first
    }

    func add(tracker: TrackerCoreData, in category: TrackerCategoryCoreData) throws {
        tracker.category = category
        category.addToTrackers(tracker)
        try context.save()
    }

    func delete(tracker: Tracker) {
        guard let trackerCoreData = self.tracker(with: tracker.id.uuidString) else { return }
        delete(trackerCoreData: trackerCoreData)
    }

    func delete(trackerCoreData: TrackerCoreData) {
        let categoryRequest = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(
            format: "%K == %@", #keyPath(TrackerCategoryCoreData.id), trackerCoreData.category.id
        )
        guard let category = try? context.fetch(categoryRequest).first else { return }

        category.removeFromTrackers(trackerCoreData)

        do {
            context.delete(trackerCoreData)
            try context.save()
        } catch {
            print(error)
        }
    }

    func pin(tracker: TrackerCoreData, pinnedCategory: TrackerCategoryCoreData) {
        let trackerWithRecords = self.trackerWithRecords(convert: tracker)

        trackerWithRecords.category = pinnedCategory
        pinnedCategory.addToTrackers(trackerWithRecords)

        do {
            delete(trackerCoreData: tracker)
            try context.save()
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
            delete(trackerCoreData: tracker)
            try context.save()
        } catch {
            assertionFailure(error.localizedDescription)
            return
        }
    }
}

private extension TrackersDataStore {
    func trackerWithRecords(convert tracker: TrackerCoreData) -> TrackerCoreData {
        let trackerWithRecords = TrackerCoreData(context: context)
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
