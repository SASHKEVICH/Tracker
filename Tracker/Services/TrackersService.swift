//
//  TrackersService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.04.2023.
//

import Foundation

protocol TrackersServiceProtocol {
    var categories: [TrackerCategory] { get }
    var completedTrackers: Set<TrackerRecord> { get }
    func fetchTrackers(for date: Date) -> [TrackerCategory]
    func requestFilterDesiredTrackers(searchText: String) -> [TrackerCategory]
    func completeTracker(trackerId id: UUID, date: Date)
    func incompleteTracker(trackerId id: UUID, date: Date)
}

final class TrackersService: TrackersServiceProtocol {
    static var shared: TrackersServiceProtocol = TrackersService()
    
    var categories: [TrackerCategory] = [
        TrackerCategory(title: "Категория 1", trackers: [
            Tracker(id: UUID(uuidString: "7E5D6688-A3F1-480E-8EE1-485A7E441E38")!, title: "Купить молоко", color: .trackerColorSelection5, emoji: "🤬", schedule: [WeekDay.monday]),
            Tracker(id: UUID(), title: "Сделать домашку", color: .trackerBlue, emoji: "🤯", schedule: [WeekDay.monday]),
            Tracker(id: UUID(), title: "Покормить кота", color: .trackerColorSelection5, emoji: "🤬", schedule: [WeekDay.monday]),
            Tracker(id: UUID(), title: "Склеить гитару", color: .trackerBlue, emoji: "🤯", schedule: [WeekDay.monday]),
        ])
    ]
    
    var completedTrackers: Set<TrackerRecord> = [
        TrackerRecord(trackerId: UUID(uuidString: "7E5D6688-A3F1-480E-8EE1-485A7E441E38")!, date: Date())
    ]
    
    func fetchTrackers(for date: Date) -> [TrackerCategory] {
        categories
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
extension TrackersService {
    func completeTracker(trackerId: UUID, date: Date) {
        let newRecord = TrackerRecord(trackerId: trackerId, date: date)
        completedTrackers.insert(newRecord)
    }
    
    func incompleteTracker(trackerId: UUID, date: Date) {
        guard let trackerToRemove = completedTrackers.first(
            where: { $0.trackerId == trackerId && Calendar.current.isDate($0.date, equalTo: date, toGranularity: .day) }
        ) else { return }
        completedTrackers.remove(trackerToRemove)
    }
}
