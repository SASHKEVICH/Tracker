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

	init(trackerRecordDataStore: TrackersRecordDataStore) {
		self.trackersRecordDataStore = trackerRecordDataStore
	}
}

extension TrackersDataCompleter: TrackersDataCompleterProtocol {
	func completeTracker(with id: String, date: Date) {
		guard let date = date.withoutTime else { return }
		try? trackersRecordDataStore.completeTracker(with: id, date: date)
	}

	func incompleteTracker(with id: String, date: Date) {
		guard let date = date.withoutTime else { return }
		guard let record = trackersRecordDataStore.record(with: id, date: date as NSDate) else { return }
		try? trackersRecordDataStore.incompleteTracker(record)
	}
}
