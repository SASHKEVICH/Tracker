//
//  Tracker.swift
//  Tracker
//
//  Created by Александр Бекренев on 03.04.2023.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
}
