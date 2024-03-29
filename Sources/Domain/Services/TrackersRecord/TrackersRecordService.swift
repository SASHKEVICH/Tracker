//
//  TrackersRecordService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation

public protocol TrackersRecordServiceDelegate: AnyObject {
    func didRecieveCompletedTrackers(_ records: [Record])
}

public protocol TrackersRecordServiceProtocol {
    var delegate: TrackersRecordServiceDelegate? { get set }
    func fetchCompletedRecords(for date: Date)
    func completedTimesCount(trackerId: UUID) -> Int
}

final class TrackersRecordService {
    weak var delegate: TrackersRecordServiceDelegate?

    private let trackersRecordDataFetcher: TrackersRecordDataFetcherProtocol

    init(trackersRecordDataFetcher: TrackersRecordDataFetcherProtocol) {
        self.trackersRecordDataFetcher = trackersRecordDataFetcher
    }
}

// MARK: - TrackersRecordServiceProtocol

extension TrackersRecordService: TrackersRecordServiceProtocol {
    func fetchCompletedRecords(for date: Date) {
        let trackerRecordsCoreData = self.trackersRecordDataFetcher.fetchCompletedRecords(date: date)
        let trackerRecords = trackerRecordsCoreData.compactMap { trackerRecordCoreData -> Record? in
            guard let id = UUID(uuidString: trackerRecordCoreData.id) else { return nil }
            return Record(trackerId: id, date: trackerRecordCoreData.date)
        }

        self.delegate?.didRecieveCompletedTrackers(trackerRecords)
    }

    func completedTimesCount(trackerId: UUID) -> Int {
        self.trackersRecordDataFetcher.completedTimesCount(trackerId: trackerId.uuidString)
    }
}
