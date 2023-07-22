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
    func completeTracker(trackerId _: UUID, date _: Date) {}
    func incompleteTracker(trackerId _: UUID, date _: Date) {}
    func addRecords(for _: Tracker, amount _: Int) {}
    func removeRecords(for _: Tracker, amount _: Int) {}
}

// MARK: - TrackersCompletingServiceStatisticsProtocol

extension TrackersCompletingServiceStub: TrackersCompletingServiceStatisticsProtocol {
    var completedTrackersCount: Int {
        5
    }
}
