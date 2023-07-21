//
//  TrackersCategoryDataFetcher.swift
//  Tracker
//
//  Created by Александр Бекренев on 16.07.2023.
//

import Foundation
import CoreData

protocol TrackersCategoryDataFetcherProtocol {
	func category(for tracker: Tracker) -> TrackerCategoryCoreData?
}

struct TrackersCategoryDataFetcher {
	private let trackersCategoryDataStore: TrackersCategoryDataStore

	init(trackersCategoryDataStore: TrackersCategoryDataStore) {
		self.trackersCategoryDataStore = trackersCategoryDataStore
	}
}

// MARK: - TrackersCategoryDataFetcherProtocol
extension TrackersCategoryDataFetcher: TrackersCategoryDataFetcherProtocol {
	func category(for tracker: Tracker) -> TrackerCategoryCoreData? {
		self.trackersCategoryDataStore.category(for: tracker)
	}
}

