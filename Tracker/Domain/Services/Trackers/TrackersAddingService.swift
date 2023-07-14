//
//  TrackersAddingService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import UIKit

protocol TrackersAddingServiceProtocol {
	func addTracker(
		title: String,
		schedule: Set<WeekDay>,
		type: Tracker.TrackerType,
		color: UIColor,
		emoji: String,
		categoryId: UUID
	)

	func delete(tracker: Tracker)
}

struct TrackersAddingService {
	private let trackersDataAdder: TrackersDataAdderProtocol
	private let trackersFactory: TrackersFactory

	init(trackersFactory: TrackersFactory, trackersDataAdder: TrackersDataAdderProtocol) {
		self.trackersFactory = trackersFactory
		self.trackersDataAdder = trackersDataAdder
	}
}

// MARK: - TrackersAddingServiceProtocol
extension TrackersAddingService: TrackersAddingServiceProtocol {
	func addTracker(
		title: String,
		schedule: Set<WeekDay>,
		type: Tracker.TrackerType,
		color: UIColor,
		emoji: String,
		categoryId: UUID
	) {
		let tracker = trackersFactory.makeTracker(
			type: type,
			title: title,
			color: color,
			emoji: emoji,
			previousCategoryId: categoryId,
			isPinned: false,
			schedule: Array(schedule)
		)
		try? self.trackersDataAdder.add(tracker: tracker, for: categoryId)
	}

	func delete(tracker: Tracker) {
		self.trackersDataAdder.delete(tracker: tracker)
	}
}
