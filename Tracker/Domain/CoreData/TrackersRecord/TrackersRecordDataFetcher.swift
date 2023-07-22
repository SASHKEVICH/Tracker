//
//  TrackersRecordFetcher.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import CoreData
import Foundation

protocol TrackersRecordDataFetcherProtocol {
    func fetchCompletedRecords(date: Date) -> [TrackerRecordCoreData]
    func completedTimesCount(trackerId: String) -> Int
}

struct TrackersRecordDataFetcher {
    private let trackersRecordDataStore: TrackersRecordDataStore

    init(trackersRecordDataStore: TrackersRecordDataStore) {
        self.trackersRecordDataStore = trackersRecordDataStore
    }
}

extension TrackersRecordDataFetcher: TrackersRecordDataFetcherProtocol {
    func fetchCompletedRecords(date: Date) -> [TrackerRecordCoreData] {
        guard let date = date.withoutTime else { return [] }
        let records = trackersRecordDataStore.completedTrackers(for: date)
        return records
    }

    func completedTimesCount(trackerId: String) -> Int {
        let count = trackersRecordDataStore.completedTimesCount(trackerId: trackerId)
        return count ?? 0
    }
}
