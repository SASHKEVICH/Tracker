//
//  TrackersCategoryFactory.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import CoreData
import Foundation

public struct TrackersCategoryFactory {
    private let trackersFactory: TrackersFactory

    public init(trackersFactory: TrackersFactory) {
        self.trackersFactory = trackersFactory
    }

    public func makeCategory(title: String, isPinning: Bool) -> TrackerCategory {
        TrackerCategory(id: UUID(), title: title, trackers: [], isPinning: isPinning)
    }

    func makeCategory(id: UUID, title: String, isPinning: Bool) -> TrackerCategory {
        TrackerCategory(id: id, title: title, trackers: [], isPinning: isPinning)
    }

    func makeCategory(categoryCoreData category: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let id = UUID(uuidString: category.id) else { return nil }
        let trackers = category.trackers
            .compactMap { $0 as? TrackerCoreData }
            .compactMap { trackersFactory.makeTracker(from: $0) }
        return TrackerCategory(id: id, title: category.title, trackers: trackers, isPinning: category.isPinning)
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
