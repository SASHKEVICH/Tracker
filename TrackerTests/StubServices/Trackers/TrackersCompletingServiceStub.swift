//
//  TrackersCompletingServiceStub.swift
//  TrackerTests
//
//  Created by Александр Бекренев on 17.07.2023.
//

import Foundation
import Tracker

final class TrackersCompletingServiceStub {
	weak var delegate: TrackersCompletingServiceStatisticsDelegate?
}

// MARK: - TrackersCompletingServiceProtocol
extension TrackersCompletingServiceStub: TrackersCompletingServiceProtocol {
	func completeTracker(trackerId id: UUID, date: Date) {}
	func incompleteTracker(trackerId id: UUID, date: Date) {}
	func addRecords(for tracker: Tracker, amount: Int) {}
	func removeRecords(for tracker: Tracker, amount: Int) {}
}

// MARK: - TrackersCompletingServiceStatisticsProtocol
extension TrackersCompletingServiceStub: TrackersCompletingServiceStatisticsProtocol {
	var completedTrackersCount: Int {
		5
	}
}
