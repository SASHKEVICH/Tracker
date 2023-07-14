//
//  TrackersDataPinner.swift
//  Tracker
//
//  Created by Александр Бекренев on 13.07.2023.
//

import Foundation
import CoreData

protocol TrackersDataPinnerProtocol {
	var delegate: TrackersPinningServiceDelegate? { get set }
	func pin(tracker: Tracker)
	func unpin(tracker: Tracker)
}

struct TrackersDataPinner {
	weak var delegate: TrackersPinningServiceDelegate?

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
	func pin(tracker: Tracker) {
		guard let pinnedCategory = self.pinnedCategory else { return }
		guard let trackerCoreData = self.trackersDataStore.tracker(with: tracker.id.uuidString) else {
			assertionFailure("Cannot find tracker with id: \(tracker.id.uuidString)")
			return
		}

		trackerCoreData.isPinned = tracker.isPinned

		self.trackersDataStore.pin(tracker: trackerCoreData, pinnedCategory: pinnedCategory)
		self.delegate?.didUpdatePinnedTrackers()
	}

	func unpin(tracker: Tracker) {
		guard let previousCategory = self.trackersCategoryDataStore.category(with: tracker.previousCategoryId.uuidString) else {
			return
		}
		guard let trackerCoreData = self.trackersDataStore.tracker(with: tracker.id.uuidString) else { return }

		trackerCoreData.isPinned = tracker.isPinned

		self.trackersDataStore.unpin(tracker: trackerCoreData, previousCategory: previousCategory)
		self.delegate?.didUpdatePinnedTrackers()
	}
}
