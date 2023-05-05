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
    func addTracker(title: String, schedule: Set<WeekDay>, type: TrackerType, color: UIColor, emoji: String)
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
final class TrackersService {
    static var shared: TrackersServiceProtocol = TrackersService()
    
    private let trackersDataProvider: TrackersDataProvider?
    
    var trackersDataProviderDelegate: TrackersDataProviderDelegate? {
        didSet {
            trackersDataProvider?.delegate = trackersDataProviderDelegate
        }
    }
    
    private init(trackerDataProvider: TrackersDataProvider?) {
        self.trackersDataProvider = trackerDataProvider
    }
    
    private convenience init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let trackerDataStore = appDelegate.trackerDataStore
        let trackerCategoryDataStore = appDelegate.trackerCategoryDataStore
        let trackerRecordDataStore = appDelegate.trackerRecordDataStore
        
        if let trackerDataProvider = TrackersDataProvider(
            trackerDataStore: trackerDataStore,
            trackerCategoryDataStore: trackerCategoryDataStore,
            trackerRecordDataStore: trackerRecordDataStore
        ) {
            self.init(trackerDataProvider: trackerDataProvider)
        } else {
            self.init(trackerDataProvider: nil)
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
        trackersDataProvider?.completeTracker(with: trackerId.uuidString, date: date)
    }
    
    func incompleteTracker(trackerId: UUID, date: Date) {
        trackersDataProvider?.incompleteTracker(with: trackerId.uuidString, date: date)
    }
}

// MARK: - TrackersServiceAddingProtocol
extension TrackersService: TrackersServiceAddingProtocol {    
    func addTracker(
        title: String,
        schedule: Set<WeekDay>,
        type: TrackerType,
        color: UIColor,
        emoji: String
    ) {
        let categoryName = "Категория 1"
        let schedule = Array(schedule)
        let tracker = Tracker(
            id: UUID(),
            type: type,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule)
        
        try? trackersDataProvider?.add(tracker: tracker, for: categoryName)
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
        guard
            let trackerCoreData = trackersDataProvider?.tracker(at: indexPath),
            let id = UUID(uuidString: trackerCoreData.id),
            let type = TrackerType(rawValue: Int(trackerCoreData.type)),
            let color = UIColorMarshalling.deserilizeFrom(hex: trackerCoreData.colorHex)
        else { return nil }
                
        let splittedWeekDays = trackerCoreData.weekDays.components(separatedBy: ", ")
        let schedule = splittedWeekDays.compactMap { String($0).weekDay }

        return Tracker(
            id: id,
            type: type,
            title: trackerCoreData.title,
            color: color,
            emoji: trackerCoreData.emoji,
            schedule: schedule)
    }
}
