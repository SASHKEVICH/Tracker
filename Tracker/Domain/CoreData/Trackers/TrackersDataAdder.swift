//
//  TrackersDataAdder.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation
import CoreData

protocol TrackersDataAdderProtocol {
	func add(tracker: Tracker, for categoryId: UUID) throws
	func delete(tracker: Tracker) throws
}

struct TrackersDataAdder {
	enum TrackersDataAdderError: Error {
		case cannotFindCategory
	}

	private let context: NSManagedObjectContext
	private let trackersDataStore: TrackersDataStore
	private let trackersCategoryDataStore: TrackersCategoryDataStore
	private let trackersFactory: TrackersFactory

	init(
		trackersCategoryDataStore: TrackersCategoryDataStore,
		trackersDataStore: TrackersDataStore,
		trackersFactory: TrackersFactory
	) {
		self.trackersCategoryDataStore = trackersCategoryDataStore
		self.trackersDataStore = trackersDataStore
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

		try trackersDataStore.add(tracker: trackersCoreData, in: categoryCoreData)
	}

	func delete(tracker: Tracker) throws {}
}
