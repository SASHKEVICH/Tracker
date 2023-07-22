//
//  TrackersDataCompleter.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation

protocol TrackersDataCompleterProtocol {
    var completedTrackersCount: Int { get }
    func completeTracker(with id: String, date: Date)
    func incompleteTracker(with id: String, date: Date)
    func addRecords(for trackerId: String, amount: Int)
    func removeRecords(for trackerId: String, amount: Int)
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
    var completedTrackersCount: Int {
        trackersRecordDataStore.completedTrackersCount() ?? 0
    }

    func completeTracker(with id: String, date: Date) {
        guard let date = date.withoutTime else { return }
        guard let tracker = trackersDataStore.tracker(with: id) else { return }

        try? trackersRecordDataStore.complete(tracker: tracker, date: date)
    }

    func incompleteTracker(with id: String, date: Date) {
        guard let date = date.withoutTime else { return }
        guard let record = trackersRecordDataStore.record(with: id, date: date as NSDate) else { return }
        guard let tracker = trackersDataStore.tracker(with: id) else { return }

        try? trackersRecordDataStore.incomplete(tracker: tracker, record: record)
    }

    func addRecords(for trackerId: String, amount: Int) {
        trackersRecordDataStore.addRecords(for: trackerId, amount: amount)
    }

    func removeRecords(for trackerId: String, amount: Int) {
        trackersRecordDataStore.removeRecords(for: trackerId, amount: amount)
    }
}
