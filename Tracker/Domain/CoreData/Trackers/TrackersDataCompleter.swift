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
        self.trackersRecordDataStore.completedTrackersCount() ?? 0
    }

    func completeTracker(with id: String, date: Date) {
        guard let date = date.withoutTime else { return }
        guard let tracker = self.trackersDataStore.tracker(with: id) else { return }

        try? self.trackersRecordDataStore.complete(tracker: tracker, date: date)
    }

    func incompleteTracker(with id: String, date: Date) {
        guard let date = date.withoutTime else { return }
        guard let record = trackersRecordDataStore.record(with: id, date: date as NSDate) else { return }
        guard let tracker = self.trackersDataStore.tracker(with: id) else { return }

        try? self.trackersRecordDataStore.incomplete(tracker: tracker, record: record)
    }

    func addRecords(for trackerId: String, amount: Int) {
        self.trackersRecordDataStore.addRecords(for: trackerId, amount: amount)
    }

    func removeRecords(for trackerId: String, amount: Int) {
        self.trackersRecordDataStore.removeRecords(for: trackerId, amount: amount)
    }
}
