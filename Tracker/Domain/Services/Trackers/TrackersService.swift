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

protocol TrackersServiceAddingProtocol {
	func addTracker(title: String, schedule: Set<WeekDay>, type: Tracker.TrackerType, color: UIColor, emoji: String)
}

protocol TrackersServiceCompletingProtocol {
    func completeTracker(trackerId id: UUID, date: Date)
    func incompleteTracker(trackerId id: UUID, date: Date)
}

protocol TrackersServiceFetchingProtocol {
    var trackersDataProviderDelegate: TrackersDataProviderDelegate? { get set }
    func fetchTrackers(weekDay: WeekDay)
    func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay)
    func fetchCompletedRecords(date: Date) -> [TrackerRecord]
    func completedTimesCount(trackerId: UUID) -> Int
    
    func requestDataProviderErrorAlert()
}

typealias TrackersServiceFetchingCompletingProtocol =
    TrackersServiceFetchingProtocol
    & TrackersServiceCompletingProtocol

typealias TrackersServiceProtocol =
    TrackersServiceAddingProtocol
    & TrackersServiceCompletingProtocol
    & TrackersServiceFetchingProtocol
    & TrackersServiceDataSourceProtocol

// MARK: - TrackersService
struct TrackersService {
    static let shared: TrackersServiceProtocol = TrackersService()

	var trackersDataProviderDelegate: TrackersDataProviderDelegate? {
		didSet {
			trackersDataProvider?.delegate = trackersDataProviderDelegate
		}
	}
    
    private let trackersDataProvider: TrackersDataProvider?
	private let trackersDataCompleter: TrackersDataCompleterProtocol
	private let trackersDataAdder: TrackersDataAdderProtocol
    
	private init(
		trackersDataProvider: TrackersDataProvider?,
		trackersDataCompleter: TrackersDataCompleterProtocol,
		trackersDataAdder: TrackersDataAdderProtocol
	) {
        self.trackersDataProvider = trackersDataProvider
		self.trackersDataCompleter = trackersDataCompleter
		self.trackersDataAdder = trackersDataAdder
    }
    
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        guard let trackerDataStore = appDelegate.trackerDataStore,
			  let trackerCategoryDataStore = appDelegate.trackerCategoryDataStore,
			  let trackerRecordDataStore = appDelegate.trackerRecordDataStore
		else { fatalError("Cannot activate data stores") }

		let trackersDataCompleter = TrackersDataCompleter(trackerRecordDataStore: trackerRecordDataStore)
		let trackersDataAdder = TrackersDataAdder(trackersCategoryDataStore: trackerCategoryDataStore, trackersDataStore: trackerDataStore)

        if let trackersDataProvider = TrackersDataProvider(
            trackerDataStore: trackerDataStore,
            trackerCategoryDataStore: trackerCategoryDataStore,
            trackerRecordDataStore: trackerRecordDataStore
        ) {
            self.init(
				trackersDataProvider: trackersDataProvider,
				trackersDataCompleter: trackersDataCompleter,
				trackersDataAdder: trackersDataAdder
			)
        } else {
			self.init(
				trackersDataProvider: nil,
				trackersDataCompleter: trackersDataCompleter,
				trackersDataAdder: trackersDataAdder
			)
            self.requestDataProviderErrorAlert()
        }
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
        let trackerRecordsCoreData = trackersDataProvider?.fetchCompletedRecords(date: date)
        let trackerRecords = trackerRecordsCoreData?.compactMap { trackerRecordCoreData -> TrackerRecord? in
            guard let id = UUID(uuidString: trackerRecordCoreData.id) else { return nil }
            return TrackerRecord(trackerId: id, date: trackerRecordCoreData.date)
        }
        return trackerRecords ?? []
    }
    
    func completedTimesCount(trackerId: UUID) -> Int {
        trackersDataProvider?.completedTimesCount(trackerId: trackerId.uuidString) ?? 0
    }
}

// MARK: - TrackersServiceCompletingProtocol
extension TrackersService: TrackersServiceCompletingProtocol {
    func completeTracker(trackerId: UUID, date: Date) {
		self.trackersDataCompleter.completeTracker(with: trackerId.uuidString, date: date)
    }
    
    func incompleteTracker(trackerId: UUID, date: Date) {
		self.trackersDataCompleter.incompleteTracker(with: trackerId.uuidString, date: date)
    }
}

// MARK: - TrackersServiceAddingProtocol
extension TrackersService: TrackersServiceAddingProtocol {    
    func addTracker(
        title: String,
        schedule: Set<WeekDay>,
		type: Tracker.TrackerType,
        color: UIColor,
        emoji: String
    ) {
        let categoryName = "Категория 1"
		let tracker = trackerFactory.makeTracker(
			type: type,
			title: title,
			color: color,
			emoji: emoji,
			schedule: Array(schedule)
		)
        
        try? trackersDataAdder.add(tracker: tracker, for: categoryName)
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
		let tracker = trackerFactory.makeTracker(from: trackerCoreData)
		return tracker
    }
}
