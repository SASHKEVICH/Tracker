//
//  TrackersCompletingService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation

protocol TrackersCompletingServiceStatisticsDelegate {
	func didChangeCompletedTrackers()
}

protocol TrackersCompletingServiceStatisticsProtocol {
	var delegate: TrackersCompletingServiceStatisticsDelegate? { get set }
	var completedTrackersCount: Int { get }
}

protocol TrackersCompletingServiceProtocol {
	func completeTracker(trackerId id: UUID, date: Date)
	func incompleteTracker(trackerId id: UUID, date: Date)
}

final class TrackersCompletingService {
	var delegate: TrackersCompletingServiceStatisticsDelegate?

	private let trackersDataCompleter: TrackersDataCompleterProtocol

	init(trackersDataCompleter: TrackersDataCompleterProtocol) {
		self.trackersDataCompleter = trackersDataCompleter
	}
}

// MARK: - TrackersCompletingServiceProtocol
extension TrackersCompletingService: TrackersCompletingServiceProtocol {
	func completeTracker(trackerId: UUID, date: Date) {
		self.trackersDataCompleter.completeTracker(with: trackerId.uuidString, date: date)
		self.delegate?.didChangeCompletedTrackers()
	}

	func incompleteTracker(trackerId: UUID, date: Date) {
		self.trackersDataCompleter.incompleteTracker(with: trackerId.uuidString, date: date)
		self.delegate?.didChangeCompletedTrackers()
	}
}

// MARK: - TrackersCompletingServiceStatisticsProtocol
extension TrackersCompletingService: TrackersCompletingServiceStatisticsProtocol {
	var completedTrackersCount: Int {
		self.trackersDataCompleter.completedTrackersCount
	}
}
