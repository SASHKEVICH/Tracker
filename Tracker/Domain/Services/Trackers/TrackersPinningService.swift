//
//  TrackersPinningService.swift
//  Tracker
//
//  Created by Александр Бекренев on 13.07.2023.
//

import UIKit

protocol TrackersPinningServiceDelegate: AnyObject {
	func didUpdatePinnedTrackers()
}

protocol TrackersPinningServiceProtocol {
	func pin(tracker: Tracker)
	func unpin(tracker: Tracker)
}

struct TrackersPinningService {
	var trackersPinnerDelegate: TrackersPinningServiceDelegate? {
		didSet {
			self.trackersDataPinner.delegate = self.trackersPinnerDelegate
		}
	}

	private var trackersDataPinner: TrackersDataPinnerProtocol
	private let trackersFactory: TrackersFactory
	private let pinnedCategoryId: UUID

	init?(pinnedCategoryId: UUID, trackersFactory: TrackersFactory) {
		self.pinnedCategoryId = pinnedCategoryId
		self.trackersFactory = trackersFactory

		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
			  let trackersDataStore = appDelegate.trackersDataStore,
			  let trackersCategoryDataStore = appDelegate.trackersCategoryDataStore
		else {
			assertionFailure("Cannot activate data store")
			return nil
		}

		self.trackersDataPinner = TrackersDataPinner(
			pinnedCategoryId: self.pinnedCategoryId,
			trackersDataStore: trackersDataStore,
			trackersCategoryDataStore: trackersCategoryDataStore
		)
	}
}

// MARK: - TrackersPinningServiceProtocol
extension TrackersPinningService: TrackersPinningServiceProtocol {
	func pin(tracker: Tracker) {
		let pinnedTracker = self.trackersFactory.makeTracker(
			id: tracker.id,
			type: tracker.type,
			title: tracker.title,
			color: tracker.color,
			emoji: tracker.emoji,
			previousCategoryId: tracker.previousCategoryId,
			isPinned: true,
			schedule: tracker.schedule
		)
		self.trackersDataPinner.pin(tracker: pinnedTracker)
	}

	func unpin(tracker: Tracker) {
		let unpinnedTracker = self.trackersFactory.makeTracker(
			id: tracker.id,
			type: tracker.type,
			title: tracker.title,
			color: tracker.color,
			emoji: tracker.emoji,
			previousCategoryId: tracker.previousCategoryId,
			isPinned: false,
			schedule: tracker.schedule
		)
		self.trackersDataPinner.unpin(tracker: unpinnedTracker)
	}
}
