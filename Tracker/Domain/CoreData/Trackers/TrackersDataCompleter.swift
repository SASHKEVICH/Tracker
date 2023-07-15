//
//  TrackersDataCompleter.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation

protocol TrackersDataCompleterProtocol {
	func completeTracker(with id: String, date: Date)
	func incompleteTracker(with id: String, date: Date)
}

struct TrackersDataCompleter {
	private let trackersRecordDataStore: TrackersRecordDataStore
	private let trackersDataStore: TrackersDataStore

	init(trackersRecordDataStore: TrackersRecordDataStore, trackersDataStore: TrackersDataStore) {
		self.trackersRecordDataStore = trackersRecordDataStore
		self.trackersDataStore = trackersDataStore
	}
}

// MARK: - TrackersDataCompleterProtocol
extension TrackersDataCompleter: TrackersDataCompleterProtocol {
	func completeTracker(with id: String, date: Date) {
		guard let date = date.withoutTime else { return }
		guard let tracker = self.trackersDataStore.tracker(with: id) else { return }

		try? self.trackersRecordDataStore.complete(tracker: tracker, date: date)
	}

	func incompleteTracker(with id: String, date: Date) {
		guard let date = date.withoutTime else { return }
		guard let record = trackersRecordDataStore.record(with: id, date: date as NSDate) else { return }
		guard let tracker = self.trackersDataStore.tracker(with: id) else { return }
		
		try? self.trackersRecordDataStore.incomplete(tracker: tracker, record: record)
	}
}
