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
    var categories: [TrackerCategory] { get }
    var completedTrackers: Set<TrackerRecord> { get }
    func fetchTrackers(for weekDay: WeekDay) -> [TrackerCategory]?
    func requestFilterDesiredTrackers(searchText: String) -> [TrackerCategory]
    
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

final class TrackersService {
    static var shared: TrackersServiceProtocol = TrackersService()
    
    private let trackersDataProvider: TrackersDataProvider?
    
    var trackersDataProviderDelegate: TrackersDataProviderDelegate? {
        didSet {
            trackersDataProvider?.delegate = trackersDataProviderDelegate
        }
    }
    
    private var privateCompletedTrackers: Set<TrackerRecord> = [
        TrackerRecord(
            trackerId: UUID(uuidString: "7E5D6688-A3F1-480E-8EE1-485A7E441E38")!,
            date: Date())
    ]
    
    private var privateCategories: [TrackerCategory] = [
        TrackerCategory(id: UUID(), title: "Категория 1", trackers: [
            Tracker(
                id: UUID(uuidString: "7E5D6688-A3F1-480E-8EE1-485A7E441E38")!,
                type: .tracker,
                title: "Купить молоко",
                color: .trackerColorSelection5,
                emoji: "🤬",
                schedule: [.monday, .thursday]),
            Tracker(
                id: UUID(),
                type: .tracker,
                title: "Сделать домашку",
                color: .trackerBlue,
                emoji: "🤯",
                schedule: [.friday]),
            Tracker(
                id: UUID(),
                type: .tracker,
                title: "Покормить кота",
                color: .trackerColorSelection5,
                emoji: "🤬",
                schedule: [.thursday]),
            Tracker(
                id: UUID(),
                type: .tracker,
                title: "Склеить гитару",
                color: .trackerBlue,
                emoji: "🤯",
                schedule: [.monday])
        ])
    ]
    
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

// MARK: - Fetching methods
extension TrackersService: TrackersServiceFetchingProtocol {
    func requestDataProviderErrorAlert() { print("data provider error") }
    
    var categories: [TrackerCategory] {
        get {
            privateCategories
        }
    }
    
    var completedTrackers: Set<TrackerRecord> {
        get {
            privateCompletedTrackers
        }
    }
    
    func fetchTrackers(for weekDay: WeekDay) -> [TrackerCategory]? {
        let filteredCategories = categories.compactMap { (oldCategory: TrackerCategory) -> TrackerCategory? in
            let categoryTrackers = oldCategory.trackers.compactMap { (tracker: Tracker) -> Tracker? in
                guard let schedule = tracker.schedule, schedule.contains(weekDay) else { return nil }
                return tracker
            }
            
            if categoryTrackers.isEmpty { return nil }
            
            return TrackerCategory(id: oldCategory.id, title: oldCategory.title, trackers: categoryTrackers)
        }
        
        return filteredCategories
    }
    
    func requestFilterDesiredTrackers(searchText: String) -> [TrackerCategory] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return [] }
        
        let lowercasedSearchText = searchText.lowercased()
        let filteredCategories: [TrackerCategory] = categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter {
                $0.title.lowercased().hasPrefix(lowercasedSearchText)
            }
            
            guard !filteredTrackers.isEmpty else { return nil }
            
            return TrackerCategory(id: category.id, title: category.title, trackers: filteredTrackers)
        }
        
        return filteredCategories
    }
}

// MARK: Completing and incompleting trackers
extension TrackersService: TrackersServiceCompletingProtocol {
    func completeTracker(trackerId: UUID, date: Date) {
        let newRecord = TrackerRecord(trackerId: trackerId, date: date)
        privateCompletedTrackers.insert(newRecord)
    }
    
    func incompleteTracker(trackerId: UUID, date: Date) {
        guard let trackerToRemove = completedTrackers.first(
            where: { $0.trackerId == trackerId && $0.date.isDayEqualTo(date) }
        ) else { return }
        privateCompletedTrackers.remove(trackerToRemove)
    }
}

extension TrackersService: TrackersServiceAddingProtocol {
//    func addTracker(
//        title: String,
//        schedule: Set<WeekDay>,
//        type: TrackerType,
//        color: UIColor,
//        emoji: String
//    ) {
//        let scheduleArray = schedule.map { $0 }
//        let newTracker = Tracker(
//            id: UUID(),
//            type: type,
//            title: title,
//            color: color,
//            emoji: emoji,
//            schedule: scheduleArray)
//
//        let oldCategory = privateCategories[0]
//        var trackers = oldCategory.trackers
//        trackers.append(newTracker)
//
//        let newCategory = TrackerCategory(title: oldCategory.title, trackers: trackers)
//
//        privateCategories.removeAll(where: { $0.title == oldCategory.title })
//        privateCategories.append(newCategory)
//    }
    
    func addTracker(
        title: String,
        schedule: Set<WeekDay>,
        type: TrackerType,
        color: UIColor,
        emoji: String
    ) {
        let categoryName = "Категория 1"
        let tracker = Tracker(
            id: UUID(),
            type: type,
            title: title,
            color: color,
            emoji: emoji,
            schedule: Array(schedule))
        
        try? trackersDataProvider?.add(tracker: tracker, for: categoryName)
    }
}

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
        
        return Tracker(
            id: id,
            type: type,
            title: trackerCoreData.title,
            color: color,
            emoji: trackerCoreData.emoji,
            schedule: nil)
    }
}
