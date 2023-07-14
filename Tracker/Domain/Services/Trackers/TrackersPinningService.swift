//
//  TrackersPinningService.swift
//  Tracker
//
//  Created by Александр Бекренев on 13.07.2023.
//

import UIKit

protocol TrackersPinningServiceProtocol {
	func pin(tracker: Tracker)
	func unpin(tracker: Tracker)
}

struct TrackersPinningService {
	private var trackersDataPinner: TrackersDataPinnerProtocol
	private let trackersFactory: TrackersFactory

	init(
		trackersFactory: TrackersFactory,
		trackersDataPinner: TrackersDataPinnerProtocol
	) {
		self.trackersFactory = trackersFactory
		self.trackersDataPinner = trackersDataPinner
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
