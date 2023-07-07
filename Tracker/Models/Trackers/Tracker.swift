//
//  Tracker.swift
//  Tracker
//
//  Created by Александр Бекренев on 03.04.2023.
//

import UIKit

struct Tracker {
	enum TrackerType: Int {
		case tracker = 1
		case irregularEvent = 2
	}

    let id: UUID
    let type: TrackerType
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
}
