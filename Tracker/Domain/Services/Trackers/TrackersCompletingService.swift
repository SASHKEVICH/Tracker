//
//  TrackersCompletingService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import UIKit

protocol TrackersCompletingServiceProtocol {
	func completeTracker(trackerId id: UUID, date: Date)
	func incompleteTracker(trackerId id: UUID, date: Date)
}

struct TrackersCompletingService {
	private let trackersDataCompleter: TrackersDataCompleterProtocol

	init() {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		guard let trackersRecordDataStore = appDelegate.trackersRecordDataStore else {
			fatalError("Cannot activate data store")
		}

		let trackersDataCompleter = TrackersDataCompleter(trackerRecordDataStore: trackersRecordDataStore)
		self.trackersDataCompleter = trackersDataCompleter
	}
}

extension TrackersCompletingService: TrackersCompletingServiceProtocol {
	func completeTracker(trackerId: UUID, date: Date) {
		self.trackersDataCompleter.completeTracker(with: trackerId.uuidString, date: date)
	}

	func incompleteTracker(trackerId: UUID, date: Date) {
		self.trackersDataCompleter.incompleteTracker(with: trackerId.uuidString, date: date)
	}
}
