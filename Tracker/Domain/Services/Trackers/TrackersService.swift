//
//  TrackersService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.04.2023.
//

import Foundation

public protocol TrackersServiceDataSourceProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func categoryTitle(at indexPath: IndexPath) -> String?
}

public protocol TrackersServiceFetchingProtocol {
    var trackersDataProviderDelegate: TrackersDataProviderDelegate? { get set }
    func tracker(at indexPath: IndexPath) -> Tracker?
    func fetchTrackers(weekDay: WeekDay)
    func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay)
    func requestDataProviderErrorAlert()
    func eraseOperations()
}

public protocol TrackersServiceFilteringProtocol {
    func performFiltering(mode: TrackerFilterViewModel.FilterMode)
}

typealias TrackersServiceProtocol = TrackersServiceFetchingProtocol & TrackersServiceDataSourceProtocol

// MARK: - TrackersService

final class TrackersService {
    weak var trackersDataProviderDelegate: TrackersDataProviderDelegate? {
        didSet {
            trackersDataProvider.delegate = trackersDataProviderDelegate
        }
    }

    private let trackersFactory: TrackersFactory
    private var trackersDataProvider: TrackersDataProviderProtocol

    init(trackersFactory: TrackersFactory, trackersDataProvider: TrackersDataProviderProtocol) {
        self.trackersFactory = trackersFactory
        self.trackersDataProvider = trackersDataProvider
    }
}

// MARK: - TrackersServiceFetchingProtocol

extension TrackersService: TrackersServiceFetchingProtocol {
    func tracker(at indexPath: IndexPath) -> Tracker? {
        guard let trackerCoreData = trackersDataProvider.tracker(at: indexPath) else { return nil }
        return trackersFactory.makeTracker(from: trackerCoreData)
    }

    func requestDataProviderErrorAlert() { print("data provider error") }

    func fetchTrackers(weekDay: WeekDay) {
        trackersDataProvider.fetchTrackers(currentWeekDay: weekDay)
    }

    func fetchTrackers(titleSearchString title: String, currentWeekDay weekDay: WeekDay) {
        trackersDataProvider.fetchTrackers(titleSearchString: title, currentWeekDay: weekDay)
    }

    func eraseOperations() {
        trackersDataProvider.eraseOperations()
    }
}

// MARK: - TrackersServiceDataSourceProtocol

extension TrackersService: TrackersServiceDataSourceProtocol {
    var numberOfSections: Int {
        trackersDataProvider.numberOfSections
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        trackersDataProvider.numberOfItemsInSection(section)
    }

    func categoryTitle(at indexPath: IndexPath) -> String? {
        trackersDataProvider.categoryTitle(at: indexPath)
    }
}

// MARK: - TrackersServiceFilteringProtocol

extension TrackersService: TrackersServiceFilteringProtocol {
    func performFiltering(mode: TrackerFilterViewModel.FilterMode) {
        switch mode {
        case let .all(currentDate):
            guard let weekDay = currentDate.weekDay else { return }
            fetchTrackers(weekDay: weekDay)
        case .today:
            trackersDataProvider.fetchTrackersForToday()
        case let .completed(currentDate):
            trackersDataProvider.fetchCompletedTrackers(for: currentDate)
        case let .incompleted(currentDate):
            trackersDataProvider.fetchIncompletedTrackers(for: currentDate)
        }
    }
}
