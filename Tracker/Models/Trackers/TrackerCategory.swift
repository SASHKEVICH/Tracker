//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Александр Бекренев on 03.04.2023.
//

import Foundation

struct TrackerCategory {
    let id: UUID
    let title: String
	let isPinning: Bool
    let trackers: [Tracker]
}
