//
//  TrackersDataPinner.swift
//  Tracker
//
//  Created by Александр Бекренев on 13.07.2023.
//

import CoreData
import Foundation

protocol TrackersDataPinnerProtocol {
    func pin(tracker: OldTrackerEntity)
    func unpin(tracker: OldTrackerEntity)
}

struct TrackersDataPinner {
    private let trackersDataStore: TrackersDataStore
    private let trackersCategoryDataStore: TrackersCategoryDataStore
    private let pinnedCategory: TrackerCategoryCoreData?

    init(
        pinnedCategoryId: UUID,
        trackersDataStore: TrackersDataStore,
        trackersCategoryDataStore: TrackersCategoryDataStore
    ) {
        self.trackersDataStore = trackersDataStore
        self.trackersCategoryDataStore = trackersCategoryDataStore
        self.pinnedCategory = self.trackersCategoryDataStore.category(with: pinnedCategoryId.uuidString)
    }
}

// MARK: - TrackersDataPinnerProtocol

extension TrackersDataPinner: TrackersDataPinnerProtocol {
    func pin(tracker: OldTrackerEntity) {
        guard let pinnedCategory = self.pinnedCategory else { return }
        guard let trackerCoreData = self.trackersDataStore.tracker(with: tracker.id.uuidString) else {
            assertionFailure("Cannot find tracker with id: \(tracker.id.uuidString)")
            return
        }

        trackerCoreData.isPinned = tracker.isPinned

        self.trackersDataStore.pin(tracker: trackerCoreData, pinnedCategory: pinnedCategory)
    }

    func unpin(tracker: OldTrackerEntity) {
        guard let previousCategory = self.trackersCategoryDataStore.category(with: tracker.previousCategoryId.uuidString) else {
            return
        }
        guard let trackerCoreData = self.trackersDataStore.tracker(with: tracker.id.uuidString) else { return }

        trackerCoreData.isPinned = tracker.isPinned

        self.trackersDataStore.unpin(tracker: trackerCoreData, previousCategory: previousCategory)
    }
}
