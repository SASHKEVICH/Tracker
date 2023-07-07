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

	init() {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		guard let trackersRecordDataStore = appDelegate.trackersRecordDataStore else {
			fatalError("Cannot activate data stores")
		}

		let trackersRecordDataFetcher = TrackersRecordDataFetcher(trackersRecordDataStore: trackersRecordDataStore)
		self.trackersRecordDataFetcher = trackersRecordDataFetcher
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
