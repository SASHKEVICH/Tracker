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
}

struct TrackersAddingService {
	private let trackersDataAdder: TrackersDataAdderProtocol
	private let trackersFactory: TrackersFactory

	init?(trackersFactory: TrackersFactory) {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
			  let trackersCategoryDataStore = appDelegate.trackersCategoryDataStore,
			  let trackersDataStore = appDelegate.trackersDataStore
		else {
			assertionFailure("Cannot activate data stores")
			return nil
		}

		self.trackersFactory = trackersFactory

		let trackersDataAdder = TrackersDataAdder(
			trackersCategoryDataStore: trackersCategoryDataStore,
			trackersDataStore: trackersDataStore,
			trackersFactory: trackersFactory
		)
		self.trackersDataAdder = trackersDataAdder
	}
}

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
			schedule: Array(schedule)
		)
		try? trackersDataAdder.add(tracker: tracker, for: categoryId)
	}
}
