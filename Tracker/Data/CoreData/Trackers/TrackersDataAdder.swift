//
//  TrackersDataAdder.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import CoreData
import Foundation

protocol TrackersDataAdderProtocol {
    func add(tracker: Tracker, for categoryId: UUID) throws
    func delete(tracker: Tracker)
    func saveEdited(tracker: Tracker, newCategoryId: UUID)
}

struct TrackersDataAdder {
    enum TrackersDataAdderError: Error {
        case cannotFindCategory
    }

    private let context: NSManagedObjectContext
    private let trackersDataStore: TrackersDataStore
    private let trackersCategoryDataStore: TrackersCategoryDataStore
    private let trackersFactory: TrackersFactory
    private let pinnedCategoryId: UUID

    init(
        trackersCategoryDataStore: TrackersCategoryDataStore,
        trackersDataStore: TrackersDataStore,
        pinnedCategoryId: UUID,
        trackersFactory: TrackersFactory
    ) {
        self.trackersCategoryDataStore = trackersCategoryDataStore
        self.trackersDataStore = trackersDataStore
        self.pinnedCategoryId = pinnedCategoryId
        self.trackersFactory = trackersFactory
        self.context = trackersDataStore.managedObjectContext
    }
}

extension TrackersDataAdder: TrackersDataAdderProtocol {
    func add(tracker: Tracker, for categoryId: UUID) throws {
        let trackersCoreData = self.trackersFactory.makeTrackerCoreData(from: tracker, context: self.context)

        guard let categoryCoreData = self.trackersCategoryDataStore.category(with: categoryId.uuidString) else {
            throw TrackersDataAdderError.cannotFindCategory
        }

        try self.trackersDataStore.add(tracker: trackersCoreData, in: categoryCoreData)
    }

    func delete(tracker: Tracker) {
        self.trackersDataStore.delete(tracker: tracker)
    }

    func saveEdited(tracker: Tracker, newCategoryId: UUID) {
        guard let newCategoryCoreData = self.trackersCategoryDataStore.category(with: newCategoryId.uuidString) else { return }
        guard let oldTrackerCoreData = self.trackersDataStore.tracker(with: tracker.id.uuidString) else { return }

        let newTrackerCoreData = self.trackersFactory.makeTrackerCoreData(from: tracker, context: self.trackersDataStore.managedObjectContext)
        newTrackerCoreData.records = oldTrackerCoreData.records

        try? self.trackersDataStore.add(tracker: newTrackerCoreData, in: newCategoryCoreData)

        self.trackersDataStore.delete(trackerCoreData: oldTrackerCoreData)
    }
}
