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
struct TrackersService {
	weak var trackersDataProviderDelegate: TrackersDataProviderDelegate? {
		didSet {
			self.trackersDataProvider.delegate = self.trackersDataProviderDelegate
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
		guard let trackerCoreData = self.trackersDataProvider.tracker(at: indexPath) else { return nil }
		return self.trackersFactory.makeTracker(from: trackerCoreData)
	}

    func requestDataProviderErrorAlert() { print("data provider error") }
    
    func fetchTrackers(weekDay: WeekDay) {
		self.trackersDataProvider.fetchTrackers(currentWeekDay: weekDay)
    }
    
    func fetchTrackers(titleSearchString title: String, currentWeekDay weekDay: WeekDay) {
		self.trackersDataProvider.fetchTrackers(titleSearchString: title, currentWeekDay: weekDay)
    }

	func eraseOperations() {
		self.trackersDataProvider.eraseOperations()
	}
}

// MARK: - TrackersServiceDataSourceProtocol
extension TrackersService: TrackersServiceDataSourceProtocol {
    var numberOfSections: Int {
		self.trackersDataProvider.numberOfSections
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
		self.trackersDataProvider.numberOfItemsInSection(section)
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String? {
		self.trackersDataProvider.categoryTitle(at: indexPath)
    }
}

// MARK: - TrackersServiceFilteringProtocol
extension TrackersService: TrackersServiceFilteringProtocol {
	func performFiltering(mode: TrackerFilterViewModel.FilterMode) {
		switch mode {
		case .all(let currentDate):
			guard let weekDay = currentDate.weekDay else { return }
			self.fetchTrackers(weekDay: weekDay)
		case .today:
			self.trackersDataProvider.fetchTrackersForToday()
		case .completed(let currentDate):
			self.trackersDataProvider.fetchCompletedTrackers(for: currentDate)
		case .incompleted(let currentDate):
			self.trackersDataProvider.fetchIncompletedTrackers(for: currentDate)
		}
	}
}
