//
//  TrackersCategoryFactory.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation
import CoreData

struct TrackersCategoryFactory {
	private let trackersFactory = TrackersFactory()

	func makeCategory(title: String, trackers: [Tracker]) -> TrackerCategory {
		return TrackerCategory(id: UUID(), title: title, trackers: trackers)
	}

	func makeCategory(categoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
		guard let id = UUID(uuidString: categoryCoreData.id) else { return nil }
		let trackers = categoryCoreData.trackers
			.compactMap { $0 as? TrackerCoreData }
			.compactMap { trackersFactory.makeTracker(from: $0) }
		return TrackerCategory(id: id, title: categoryCoreData.title, trackers: trackers)
	}

	func makeCategoryCoreData(
		from category: TrackerCategory,
		context: NSManagedObjectContext
	) -> TrackerCategoryCoreData {
		let categoryCoreData = TrackerCategoryCoreData(context: context)
		categoryCoreData.id = category.id.uuidString
		categoryCoreData.title = category.title
		categoryCoreData.trackers = NSSet(array: category.trackers)
		return categoryCoreData
	}
}
