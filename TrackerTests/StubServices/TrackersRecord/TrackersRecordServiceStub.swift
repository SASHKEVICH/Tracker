//
//  TrackersRecordServiceStub.swift
//  TrackerTests
//
//  Created by Александр Бекренев on 17.07.2023.
//

import Foundation
import Tracker

final class TrackersRecordServiceStub {
    weak var delegate: TrackersRecordServiceDelegate?
}

// MARK: - TrackersRecordServiceProtocol

extension TrackersRecordServiceStub: TrackersRecordServiceProtocol {
    func fetchCompletedRecords(for _: Date) {}

    func completedTimesCount(trackerId _: UUID) -> Int {
        0
    }
}
