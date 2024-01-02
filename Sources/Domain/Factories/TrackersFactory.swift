//
//  TrackersFactory.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import CoreData
import UIKit

public struct TrackersFactory {
    public init() {}

    public func makeTracker(
        type: OldTrackerEntity.TrackerType,
        title: String,
        color: UIColor,
        emoji: String,
        previousCategoryId: UUID,
        isPinned: Bool,
        schedule: [WeekDay]
    ) -> OldTrackerEntity {
        return OldTrackerEntity(
            id: UUID(),
            previousCategoryId: previousCategoryId,
            type: type,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isPinned: isPinned
        )
    }

    func makeTracker(
        id: UUID,
        type: OldTrackerEntity.TrackerType,
        title: String,
        color: UIColor,
        emoji: String,
        previousCategoryId: UUID,
        isPinned: Bool,
        schedule: [WeekDay]
    ) -> OldTrackerEntity {
        return OldTrackerEntity(
            id: id,
            previousCategoryId: previousCategoryId,
            type: type,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isPinned: isPinned
        )
    }

    func makeTracker(from trackerCoreData: TrackerCoreData) -> OldTrackerEntity? {
        guard let id = UUID(uuidString: trackerCoreData.id),
              let previousCategoryId = UUID(uuidString: trackerCoreData.previousCategoryId),
              let type = OldTrackerEntity.TrackerType(rawValue: Int(trackerCoreData.type)),
              let color = UIColorMarshalling.deserilizeFrom(hex: trackerCoreData.colorHex)
        else { return nil }

        let splittedWeekDays = trackerCoreData.weekDays.components(separatedBy: ", ")
        let schedule = splittedWeekDays.compactMap { String($0).weekDay }

        return OldTrackerEntity(
            id: id,
            previousCategoryId: previousCategoryId,
            type: type,
            title: trackerCoreData.title,
            color: color,
            emoji: trackerCoreData.emoji,
            schedule: schedule,
            isPinned: trackerCoreData.isPinned
        )
    }

    func makeTrackerCoreData(from tracker: OldTrackerEntity, context: NSManagedObjectContext) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        return editTrackerCoreData(from: tracker, trackerCoreData: trackerCoreData)
    }

    func editTrackerCoreData(from tracker: OldTrackerEntity, trackerCoreData: TrackerCoreData) -> TrackerCoreData {
        trackerCoreData.id = tracker.id.uuidString
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = UIColorMarshalling.serilizeToHex(color: tracker.color)
        trackerCoreData.previousCategoryId = tracker.previousCategoryId.uuidString
        trackerCoreData.type = Int16(tracker.type.rawValue)
        trackerCoreData.isPinned = tracker.isPinned

        let schedule = tracker.schedule.reduce("") { $0 + ", " + $1.englishStringRepresentation }
        trackerCoreData.weekDays = schedule
        return trackerCoreData
    }
}
