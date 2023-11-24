//
//  TrackersCategoryDataFetcher.swift
//  Tracker
//
//  Created by Александр Бекренев on 16.07.2023.
//

import CoreData
import Foundation

protocol TrackersCategoryDataFetcherProtocol {
    func category(for tracker: OldTrackerEntity) -> TrackerCategoryCoreData?
}

struct TrackersCategoryDataFetcher {
    private let trackersCategoryDataStore: TrackersCategoryDataStore

    init(trackersCategoryDataStore: TrackersCategoryDataStore) {
        self.trackersCategoryDataStore = trackersCategoryDataStore
    }
}

// MARK: - TrackersCategoryDataFetcherProtocol

extension TrackersCategoryDataFetcher: TrackersCategoryDataFetcherProtocol {
    func category(for tracker: OldTrackerEntity) -> TrackerCategoryCoreData? {
        self.trackersCategoryDataStore.category(for: tracker)
    }
}
