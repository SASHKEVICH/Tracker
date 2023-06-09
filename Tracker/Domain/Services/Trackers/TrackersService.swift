//
//  TrackersService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.04.2023.
//

import UIKit

protocol TrackersServiceDataSourceProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker?
    func categoryTitle(at indexPath: IndexPath) -> String?
}

protocol TrackersServiceFetchingProtocol {
    var trackersDataProviderDelegate: TrackersDataProviderDelegate? { get set }
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
    
    init?(trackersFactory: TrackersFactory) {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
			  let trackersDataStore = appDelegate.trackersDataStore
		else {
			assertionFailure("Cannot activate data stores")
			return nil
		}

		self.trackersFactory = trackersFactory
		self.trackersDataProvider = TrackersDataProvider(context: trackersDataStore.managedObjectContext)
    }
}

// MARK: - TrackersServiceFetchingProtocol
extension TrackersService: TrackersServiceFetchingProtocol {
    func requestDataProviderErrorAlert() { print("data provider error") }
    
    func fetchTrackers(weekDay: WeekDay) {
        trackersDataProvider.fetchTrackers(currentWeekDay: weekDay)
        trackersDataProviderDelegate?.didRecievedTrackers()
    }
    
    func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay) {
        trackersDataProvider.fetchTrackers(titleSearchString: titleSearchString, currentWeekDay: currentWeekDay)
        trackersDataProviderDelegate?.didRecievedTrackers()
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
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
		guard let trackerCoreData = trackersDataProvider.tracker(at: indexPath) else { return nil }
		let tracker = trackersFactory.makeTracker(from: trackerCoreData)
		return tracker
    }
}
