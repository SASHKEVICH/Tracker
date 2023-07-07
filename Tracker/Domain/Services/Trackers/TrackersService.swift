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
    func fetchCompletedRecords(date: Date) -> [TrackerRecord]
    func completedTimesCount(trackerId: UUID) -> Int
    
    func requestDataProviderErrorAlert()
}

typealias TrackersServiceProtocol = TrackersServiceFetchingProtocol & TrackersServiceDataSourceProtocol

// MARK: - TrackersService
struct TrackersService {
    static let shared: TrackersServiceProtocol = TrackersService()

	var trackersDataProviderDelegate: TrackersDataProviderDelegate? {
		didSet {
			trackersDataProvider?.delegate = trackersDataProviderDelegate
		}
	}
    
    private let trackersDataProvider: TrackersDataProvider?
	private let trackersRecordDataFetcher: TrackersRecordDataFetcherProtocol

	private let trackersFactory = TrackersFactory()
    
	private init(
		trackersDataProvider: TrackersDataProvider?,
		trackersRecordDataFetcher: TrackersRecordDataFetcherProtocol
	) {
        self.trackersDataProvider = trackersDataProvider
		self.trackersRecordDataFetcher = trackersRecordDataFetcher
    }
    
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let trackersDataStore = appDelegate.trackersDataStore,
			  let trackersRecordDataStore = appDelegate.trackersRecordDataStore
		else { fatalError("Cannot activate data stores") }

		let trackersRecordDataFetcher = TrackersRecordDataFetcher(trackersRecordDataStore: trackersRecordDataStore)

		let trackersDataProvider = TrackersDataProvider(context: trackersDataStore.managedObjectContext)
		self.init(
			trackersDataProvider: trackersDataProvider,
			trackersRecordDataFetcher: trackersRecordDataFetcher
		)
    }
}

// MARK: - TrackersServiceFetchingProtocol
extension TrackersService: TrackersServiceFetchingProtocol {
    func requestDataProviderErrorAlert() { print("data provider error") }
    
    func fetchTrackers(weekDay: WeekDay) {
        trackersDataProvider?.fetchTrackers(currentWeekDay: weekDay)
        trackersDataProviderDelegate?.didRecievedTrackers()
    }
    
    func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay) {
        trackersDataProvider?.fetchTrackers(titleSearchString: titleSearchString, currentWeekDay: currentWeekDay)
        trackersDataProviderDelegate?.didRecievedTrackers()
    }
    
    func fetchCompletedRecords(date: Date) -> [TrackerRecord] {
        let trackerRecordsCoreData = trackersRecordDataFetcher.fetchCompletedRecords(date: date)
        let trackerRecords = trackerRecordsCoreData.compactMap { trackerRecordCoreData -> TrackerRecord? in
            guard let id = UUID(uuidString: trackerRecordCoreData.id) else { return nil }
            return TrackerRecord(trackerId: id, date: trackerRecordCoreData.date)
        }
        return trackerRecords
    }
    
    func completedTimesCount(trackerId: UUID) -> Int {
        trackersRecordDataFetcher.completedTimesCount(trackerId: trackerId.uuidString)
    }
}

// MARK: - TrackersServiceDataSourceProtocol
extension TrackersService: TrackersServiceDataSourceProtocol {
    var numberOfSections: Int {
        trackersDataProvider?.numberOfSections ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        trackersDataProvider?.numberOfItemsInSection(section) ?? 0
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String? {
        trackersDataProvider?.categoryTitle(at: indexPath)
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
		guard let trackerCoreData = trackersDataProvider?.tracker(at: indexPath) else { return nil }
		let tracker = trackersFactory.makeTracker(from: trackerCoreData)
		return tracker
    }
}
