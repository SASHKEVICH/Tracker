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
    func completeTracker(trackerId id: UUID, date: Date)
    func incompleteTracker(trackerId id: UUID, date: Date)
}

final class TrackersService: TrackersServiceProtocol {
    var categories: [TrackerCategory] = []
    var completedTrackers: Set<TrackerRecord> = [
        TrackerRecord(trackerId: UUID(uuidString: "7E5D6688-A3F1-480E-8EE1-485A7E441E38")!, date: Date())
    ]
    
    static var shared: TrackersServiceProtocol = TrackersService()
    
    func fetchTrackers(for date: Date) -> [TrackerCategory] {
        let categories = [
            TrackerCategory(title: "Категория 1", trackers: [
                Tracker(id: UUID(uuidString: "7E5D6688-A3F1-480E-8EE1-485A7E441E38")!, title: "Тестовая привычка 1", color: .trackerColorSelection5, emoji: "🤬", schedule: [WeekDay.monday]),
                Tracker(id: UUID(), title: "Тестовая привычка 2", color: .trackerBlue, emoji: "🤯", schedule: [WeekDay.monday]),
            ]),
            TrackerCategory(title: "Категория 2", trackers: [
                Tracker(id: UUID(), title: "Тестовая привычка 3", color: .trackerColorSelection5, emoji: "🤬", schedule: [WeekDay.monday]),
                Tracker(id: UUID(), title: "Тестовая привычка 4", color: .trackerBlue, emoji: "🤯", schedule: [WeekDay.monday]),
            ])
        ]

        return categories
    }
    
    func completeTracker(trackerId: UUID, date: Date) {
        let newRecord = TrackerRecord(trackerId: trackerId, date: date)
        completedTrackers.insert(newRecord)
    }
    
    func incompleteTracker(trackerId: UUID, date: Date) {
        let completeTrackersWithoutNewIncompleted = completedTrackers
            .filter { $0.trackerId != trackerId && $0.date != date }
        self.completedTrackers = completeTrackersWithoutNewIncompleted
    }
}
