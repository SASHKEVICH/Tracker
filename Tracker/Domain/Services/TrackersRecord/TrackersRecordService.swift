//
//  TrackersRecordService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import UIKit

protocol TrackersRecordServiceProtocol {
	func fetchCompletedRecords(date: Date) -> [TrackerRecord]
	func completedTimesCount(trackerId: UUID) -> Int
}

struct TrackersRecordService {
	private let trackersRecordDataFetcher: TrackersRecordDataFetcherProtocol

	init?() {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
			  let trackersRecordDataStore = appDelegate.trackersRecordDataStore
		else {
			assertionFailure("Cannot activate data stores")
			return nil
		}

		self.trackersRecordDataFetcher = TrackersRecordDataFetcher(trackersRecordDataStore: trackersRecordDataStore)
	}
}

extension TrackersRecordService: TrackersRecordServiceProtocol {
	func fetchCompletedRecords(date: Date) -> [TrackerRecord] {
		let trackerRecordsCoreData = trackersRecordDataFetcher.fetchCompletedRecords(date: date)
		let trackerRecords = trackerRecordsCoreData.compactMap { trackerRecordCoreData -> TrackerRecord? in
			guard let id = UUID(uuidString: trackerRecordCoreData.id) else { return nil }
			return TrackerRecord(trackerId: id, date: trackerRecordCoreData.date)
		}
		return trackerRecords
	}

	func completedTimesCount(trackerId: UUID) -> Int {
		trackersRecordDataFetcher.completedTimesCount(trackerId: trackerId.uuidString)
	}
}
