//
//  TrackersFactory.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import UIKit
import CoreData

public struct TrackersFactory {
	public init() {}

	public func makeTracker(
		type: Tracker.TrackerType,
		title: String,
		color: UIColor,
		emoji: String,
		previousCategoryId: UUID,
		isPinned: Bool,
		schedule: [WeekDay]
	) -> Tracker {
		return Tracker(
			id: UUID(),
			previousCategoryId: previousCategoryId,
			type: type,
			title: title,
			color: color,
			emoji: emoji,
			isPinned: isPinned,
			schedule: schedule
		)
	}

	func makeTracker(
		id: UUID,
		type: Tracker.TrackerType,
		title: String,
		color: UIColor,
		emoji: String,
		previousCategoryId: UUID,
		isPinned: Bool,
		schedule: [WeekDay]
	) -> Tracker {
		return Tracker(
			id: id,
			previousCategoryId: previousCategoryId,
			type: type,
			title: title,
			color: color,
			emoji: emoji,
			isPinned: isPinned,
			schedule: schedule
		)
	}

	func makeTracker(from trackerCoreData: TrackerCoreData) -> Tracker? {
		guard let id = UUID(uuidString: trackerCoreData.id),
			  let previousCategoryId = UUID(uuidString: trackerCoreData.previousCategoryId),
			  let type = Tracker.TrackerType(rawValue: Int(trackerCoreData.type)),
			  let color = UIColorMarshalling.deserilizeFrom(hex: trackerCoreData.colorHex)
		else { return nil }

		let splittedWeekDays = trackerCoreData.weekDays.components(separatedBy: ", ")
		let schedule = splittedWeekDays.compactMap { String($0).weekDay }

		return Tracker(
			id: id,
			previousCategoryId: previousCategoryId,
			type: type,
			title: trackerCoreData.title,
			color: color,
			emoji: trackerCoreData.emoji,
			isPinned: trackerCoreData.isPinned,
			schedule: schedule
		)
	}

	func makeTrackerCoreData(from tracker: Tracker, context: NSManagedObjectContext) -> TrackerCoreData {
		let trackerCoreData = TrackerCoreData(context: context)
		return editTrackerCoreData(from: tracker, trackerCoreData: trackerCoreData)
	}

	func editTrackerCoreData(from tracker: Tracker, trackerCoreData: TrackerCoreData) -> TrackerCoreData {
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
