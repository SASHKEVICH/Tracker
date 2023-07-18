//
//  TrackersAddingService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import UIKit

public protocol TrackersAddingServiceProtocol {
	func addTracker(
		title: String,
		schedule: Set<WeekDay>,
		type: Tracker.TrackerType,
		color: UIColor,
		emoji: String,
		categoryId: UUID
	)

	func delete(tracker: Tracker)

	func saveEdited(
		trackerId: UUID,
		title: String,
		schedule: Set<WeekDay>,
		type: Tracker.TrackerType,
		color: UIColor,
		emoji: String,
		newCategoryId: UUID,
		previousCategoryId: UUID,
		isPinned: Bool
	)
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
		let newTracker = trackersFactory.makeTracker(
			type: type,
			title: title,
			color: color,
			emoji: emoji,
			previousCategoryId: categoryId,
			isPinned: false,
			schedule: Array(schedule)
		)
		try? self.trackersDataAdder.add(tracker: newTracker, for: categoryId)
	}

	func delete(tracker: Tracker) {
		self.trackersDataAdder.delete(tracker: tracker)
	}

	func saveEdited(
		trackerId: UUID,
		title: String,
		schedule: Set<WeekDay>,
		type: Tracker.TrackerType,
		color: UIColor,
		emoji: String,
		newCategoryId: UUID,
		previousCategoryId: UUID,
		isPinned: Bool
	) {
		let editedTracker = self.trackersFactory.makeTracker(
			id: trackerId,
			type: type,
			title: title,
			color: color,
			emoji: emoji,
			previousCategoryId: previousCategoryId,
			isPinned: isPinned,
			schedule: Array(schedule)
		)
		self.trackersDataAdder.saveEdited(tracker: editedTracker, newCategoryId: newCategoryId)
	}
}
