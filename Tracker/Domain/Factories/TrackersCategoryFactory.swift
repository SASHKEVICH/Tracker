//
//  TrackersCategoryFactory.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation
import CoreData

struct TrackersCategoryFactory {
	private let trackersFactory: TrackersFactory

	init(trackersFactory: TrackersFactory) {
		self.trackersFactory = trackersFactory
	}

	func makeCategory(title: String, isPinning: Bool) -> TrackerCategory {
		TrackerCategory(id: UUID(), title: title, isPinning: isPinning, trackers: [])
	}

	func makeCategory(categoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
		guard let id = UUID(uuidString: categoryCoreData.id) else { return nil }
		let trackers = categoryCoreData.trackers
			.compactMap { $0 as? TrackerCoreData }
			.compactMap { trackersFactory.makeTracker(from: $0) }
		return TrackerCategory(id: id, title: categoryCoreData.title, isPinning: categoryCoreData.isPinning, trackers: trackers)
	}

	func makeCategoryCoreData(
		from category: TrackerCategory,
		context: NSManagedObjectContext
	) -> TrackerCategoryCoreData {
		let categoryCoreData = TrackerCategoryCoreData(context: context)
		categoryCoreData.id = category.id.uuidString
		categoryCoreData.title = category.title
		categoryCoreData.isPinning = category.isPinning
		categoryCoreData.trackers = NSSet(array: category.trackers)
		return categoryCoreData
	}
}
