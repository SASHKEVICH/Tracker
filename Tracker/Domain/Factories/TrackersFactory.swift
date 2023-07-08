//
//  TrackersFactory.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import UIKit
import CoreData

struct TrackersFactory {
	func makeTracker(
		type: Tracker.TrackerType,
		title: String,
		color: UIColor,
		emoji: String,
		schedule: [WeekDay]
	) -> Tracker {
		return Tracker(
			id: UUID(),
			type: type,
			title: title,
			color: color,
			emoji: emoji,
			schedule: schedule
		)
	}

	func makeTracker(from trackerCoreData: TrackerCoreData) -> Tracker? {
		guard let id = UUID(uuidString: trackerCoreData.id),
			  let type = Tracker.TrackerType(rawValue: Int(trackerCoreData.type)),
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
			schedule: schedule
		)
	}

	func makeTrackerCoreData(from tracker: Tracker, context: NSManagedObjectContext) -> TrackerCoreData {
		let trackerCoreData = TrackerCoreData(context: context)
		trackerCoreData.title = tracker.title
		trackerCoreData.emoji = tracker.emoji
		trackerCoreData.colorHex = UIColorMarshalling.serilizeToHex(color: tracker.color)
		trackerCoreData.id = tracker.id.uuidString
		trackerCoreData.type = Int16(tracker.type.rawValue)

		let schedule = tracker.schedule.reduce("") { $0 + ", " + $1.englishStringRepresentation }
		trackerCoreData.weekDays = schedule
		return trackerCoreData
	}
}
