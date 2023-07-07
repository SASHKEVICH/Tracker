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
	private let trackerRecordDataStore: TrackerRecordDataStore

	init(trackerRecordDataStore: TrackerRecordDataStore) {
		self.trackerRecordDataStore = trackerRecordDataStore
	}
}

extension TrackersDataCompleter: TrackersDataCompleterProtocol {
	func completeTracker(with id: String, date: Date) {
		guard let date = date.onlyDate else { return }
		try? trackerRecordDataStore.completeTracker(with: id, date: date)
	}

	func incompleteTracker(with id: String, date: Date) {
		guard let date = date.onlyDate else { return }
		guard let record = trackerRecordDataStore.record(with: id, date: date as NSDate) else { return }
		try? trackerRecordDataStore.incompleteTracker(record)
	}
}
