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
    
    func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay) {
		self.trackersDataProvider.fetchTrackers(titleSearchString: titleSearchString, currentWeekDay: currentWeekDay)
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
