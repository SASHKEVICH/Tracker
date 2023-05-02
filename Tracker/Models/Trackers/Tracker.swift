//
//  Tracker.swift
//  Tracker
//
//  Created by Александр Бекренев on 03.04.2023.
//

import UIKit

enum TrackerType: Int {
    case tracker = 1
    case irregularEvent = 2
}

struct Tracker {
    let id: UUID
    let type: TrackerType
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]?
}
