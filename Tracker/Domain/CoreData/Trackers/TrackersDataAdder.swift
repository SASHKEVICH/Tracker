//
//  TrackersDataAdder.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation
import CoreData

protocol TrackersDataAdderProtocol {
	func add(tracker: Tracker, for categoryName: String) throws
	func delete(tracker: Tracker) throws
}

struct TrackersDataAdder {
	enum TrackersDataAdderError: Error {
		case cannotFindCategory
	}

	private let context: NSManagedObjectContext
	private let trackersDataStore: TrackersDataStore
	private let trackersCategoryDataStore: TrackerCategoryDataStore

	private let trackersFactory = TrackersFactory()

	init(trackersCategoryDataStore: TrackerCategoryDataStore, trackersDataStore: TrackersDataStore) {
		self.trackersCategoryDataStore = trackersCategoryDataStore
		self.trackersDataStore = trackersDataStore
		self.context = trackersDataStore.managedObjectContext
	}
}

extension TrackersDataAdder: TrackersDataAdderProtocol {
	func add(tracker: Tracker, for categoryName: String) throws {
		let trackerCoreData = self.trackersFactory.makeTrackerCoreData(from: tracker, context: self.context)

		guard let categoryCoreData = self.trackersCategoryDataStore.category(with: categoryName) else {
			throw TrackersDataAdderError.cannotFindCategory
		}

		try trackersDataStore.add(tracker: trackerCoreData, in: categoryCoreData)
	}

	func delete(tracker: Tracker) throws {}
}
