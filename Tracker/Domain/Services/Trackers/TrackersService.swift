//
//  TrackersService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.04.2023.
//

import Foundation

protocol TrackersServiceDataSourceProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func categoryTitle(at indexPath: IndexPath) -> String?
}

protocol TrackersServiceFetchingProtocol {
    var trackersDataProviderDelegate: TrackersDataProviderDelegate? { get set }
	var trackers: [Tracker] { get }
    func fetchTrackers(weekDay: WeekDay)
    func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay)
    func requestDataProviderErrorAlert()
	func eraseOperations()
}

protocol TrackersServiceFilteringProtocol {
	func performFiltering(mode: TrackerFilterViewModel.FilterMode)
}

typealias TrackersServiceProtocol = TrackersServiceFetchingProtocol & TrackersServiceDataSourceProtocol

// MARK: - TrackersService
struct TrackersService {
	var trackersDataProviderDelegate: TrackersDataProviderDelegate? {
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
	var trackers: [Tracker] {
		let trackersCoreData = self.trackersDataProvider.trackers
		return trackersCoreData.compactMap { self.trackersFactory.makeTracker(from: $0) }
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
		case .completed:
			break
		case .incompleted:
			break
		}
	}
}
