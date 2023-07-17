//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Александр Бекренев on 03.04.2023.
//

import Foundation

public struct TrackerRecord: Hashable {
    let trackerId: UUID
    let date: Date
}
