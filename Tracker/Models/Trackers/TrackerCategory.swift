//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Александр Бекренев on 03.04.2023.
//

import Foundation

public struct TrackerCategory: Equatable {
    public static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        lhs.id == rhs.id
    }

    let id: UUID
    let title: String
    let trackers: [Tracker]
    let isPinning: Bool
}
