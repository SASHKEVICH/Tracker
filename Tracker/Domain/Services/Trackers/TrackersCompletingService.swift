//
//  TrackersCompletingService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation

public protocol TrackersCompletingServiceStatisticsDelegate: AnyObject {
    func didChangeCompletedTrackers()
}

public protocol TrackersCompletingServiceStatisticsProtocol {
    var delegate: TrackersCompletingServiceStatisticsDelegate? { get set }
    var completedTrackersCount: Int { get }
}

public protocol TrackersCompletingServiceProtocol {
    func completeTracker(trackerId id: UUID, date: Date)
    func incompleteTracker(trackerId id: UUID, date: Date)

    func addRecords(for tracker: Tracker, amount: Int)
    func removeRecords(for tracker: Tracker, amount: Int)
}

final class TrackersCompletingService {
    weak var delegate: TrackersCompletingServiceStatisticsDelegate?

    private let trackersDataCompleter: TrackersDataCompleterProtocol

    init(trackersDataCompleter: TrackersDataCompleterProtocol) {
        self.trackersDataCompleter = trackersDataCompleter
    }
}

// MARK: - TrackersCompletingServiceProtocol

extension TrackersCompletingService: TrackersCompletingServiceProtocol {
    func completeTracker(trackerId: UUID, date: Date) {
        trackersDataCompleter.completeTracker(with: trackerId.uuidString, date: date)
        delegate?.didChangeCompletedTrackers()
    }

    func incompleteTracker(trackerId: UUID, date: Date) {
        trackersDataCompleter.incompleteTracker(with: trackerId.uuidString, date: date)
        delegate?.didChangeCompletedTrackers()
    }

    func addRecords(for tracker: Tracker, amount: Int) {
        trackersDataCompleter.addRecords(for: tracker.id.uuidString, amount: amount)
        delegate?.didChangeCompletedTrackers()
    }

    func removeRecords(for tracker: Tracker, amount: Int) {
        trackersDataCompleter.removeRecords(for: tracker.id.uuidString, amount: amount)
        delegate?.didChangeCompletedTrackers()
    }
}

// MARK: - TrackersCompletingServiceStatisticsProtocol

extension TrackersCompletingService: TrackersCompletingServiceStatisticsProtocol {
    var completedTrackersCount: Int {
        trackersDataCompleter.completedTrackersCount
    }
}
