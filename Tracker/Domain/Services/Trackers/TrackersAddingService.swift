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
	private let trackersFactory = TrackersFactory()
	private let trackersDataAdder: TrackersDataAdderProtocol

	init() {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		guard let trackersCategoryDataStore = appDelegate.trackersCategoryDataStore,
			  let trackersDataStore = appDelegate.trackersDataStore
		else { fatalError("Cannot activate data stores") }

		let trackersDataAdder = TrackersDataAdder(
			trackersCategoryDataStore: trackersCategoryDataStore,
			trackersDataStore: trackersDataStore
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
