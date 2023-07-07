//
//  TrackersRecordFetcher.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation
import CoreData

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
		guard let onlyDate = date.onlyDate else { return [] }
		let trackerRecordsCoreData = trackersRecordDataStore.completedTrackers(for: onlyDate as NSDate)
		return trackerRecordsCoreData
	}

	func completedTimesCount(trackerId: String) -> Int {
		let count = try? trackersRecordDataStore.completedTimesCount(trackerId: trackerId)
		return count ?? 0
	}
}
