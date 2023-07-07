//
//  TrackerFactory.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import UIKit

struct TrackerFactory {
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
}
