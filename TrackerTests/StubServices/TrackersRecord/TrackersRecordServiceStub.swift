//
//  TrackersRecordServiceStub.swift
//  TrackerTests
//
//  Created by Александр Бекренев on 17.07.2023.
//

import Foundation
import Tracker

final class TrackersRecordServiceStub {
	var delegate: TrackersRecordServiceDelegate?
}

// MARK: - TrackersRecordServiceProtocol
extension TrackersRecordServiceStub: TrackersRecordServiceProtocol {
	func fetchCompletedRecords(for date: Date) {}

	func completedTimesCount(trackerId: UUID) -> Int {
		0
	}
}
