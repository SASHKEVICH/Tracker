//
//  TrackersService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.04.2023.
//

import UIKit

protocol TrackersServiceAddingProtocol {
    func addTracker(title: String, schedule: Set<WeekDay>, type: TrackerType, color: UIColor, emoji: String)
    func addCategory(title: String, trackers: [Tracker])
    func category(at indexPath: IndexPath) -> TrackerCategory?
    func allCategories() -> [TrackerCategory]
    func removeCategory(at indexPath: IndexPath)
    func fetchTrackers(for currentDate: Date)
}

protocol TrackersServiceCompletingProtocol {
    func completeTracker(trackerId id: UUID, date: Date)
    func incompleteTracker(trackerId id: UUID, date: Date)
}

protocol TrackersServiceFetchingProtocol {
    var categories: [TrackerCategory] { get }
    var completedTrackers: Set<TrackerRecord> { get }
    func fetchTrackers(for weekDay: WeekDay) -> [TrackerCategory]?
    func requestFilterDesiredTrackers(searchText: String) -> [TrackerCategory]
}

typealias TrackersServiceFetchingCompletingProtocol =
    TrackersServiceFetchingProtocol
    & TrackersServiceCompletingProtocol

typealias TrackersServiceProtocol =
    TrackersServiceAddingProtocol
    & TrackersServiceCompletingProtocol
    & TrackersServiceFetchingProtocol

final class TrackersService {
    static var shared: TrackersServiceProtocol = TrackersService()
    
    private var trackersDataProvider: TrackersDataProviderProtocol?
    weak var dataProviderDelegate: TrackersDataProviderDelegate?
    
    private var privateCompletedTrackers: Set<TrackerRecord> = [
        TrackerRecord(
            trackerId: UUID(uuidString: "7E5D6688-A3F1-480E-8EE1-485A7E441E38")!,
            date: Date())
    ]
    
    private var privateCategories: [TrackerCategory] = [
        TrackerCategory(title: "Категория 1", trackers: [
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
    
    init(trackersDataProvider: TrackersDataProviderProtocol?) {
        self.trackersDataProvider = trackersDataProvider
    }
    
    convenience init() {
        self.init(trackersDataProvider: try? TrackersDataProvider())
        
        self.trackersDataProvider?.delegate = dataProviderDelegate
    }
}

// MARK: - Fetching methods
extension TrackersService: TrackersServiceFetchingProtocol {
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
            
            return TrackerCategory(title: oldCategory.title, trackers: categoryTrackers)
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
            
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
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
    func addTracker(
        title: String,
        schedule: Set<WeekDay>,
        type: TrackerType,
        color: UIColor,
        emoji: String
    ) {
        let scheduleArray = schedule.map { $0 }
        let newTracker = Tracker(
            id: UUID(),
            type: type,
            title: title,
            color: color,
            emoji: emoji,
            schedule: scheduleArray)
        
        let oldCategory = privateCategories[0]
        var trackers = oldCategory.trackers
        trackers.append(newTracker)
        
        let newCategory = TrackerCategory(title: oldCategory.title, trackers: trackers)
        
        privateCategories.removeAll(where: { $0.title == oldCategory.title })
        privateCategories.append(newCategory)
    }
    
    func addCategory(title: String, trackers: [Tracker]) {
        let category = TrackerCategory(title: title, trackers: trackers)
        trackersDataProvider?.add(category: category)
    }
    
    func category(at indexPath: IndexPath) -> TrackerCategory? {
        trackersDataProvider?.object(at: indexPath)
    }
    
    func removeCategory(at indexPath: IndexPath) {
        trackersDataProvider?.removeCategory(at: indexPath)
    }
    
    func allCategories() -> [TrackerCategory] {
        trackersDataProvider?.allCategories() ?? []
    }
    
    func fetchTrackers(for currentDate: Date) {
        guard let weekday = currentDate.weekDay else { return }
        trackersDataProvider?.fetchTrackers(for: weekday.englishStringRepresentation)
    }
}
