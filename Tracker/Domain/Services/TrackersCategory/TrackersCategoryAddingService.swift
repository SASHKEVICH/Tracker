//
//  TrackersCategoryAddingService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation

public protocol TrackersCategoryAddingServiceProtocol {
    func addCategory(title: String)
}

final class TrackersCategoryAddingService {
    private let trackersCategoryDataAdder: TrackersCategoryDataAdderProtocol
    private let trackersCategoryFactory: TrackersCategoryFactory

    init(trackersCategoryFactory: TrackersCategoryFactory, trackersCategoryDataAdder: TrackersCategoryDataAdderProtocol) {
        self.trackersCategoryFactory = trackersCategoryFactory
        self.trackersCategoryDataAdder = trackersCategoryDataAdder
    }
}

// MARK: - TrackersCategoryAddingServiceProtocol

extension TrackersCategoryAddingService: TrackersCategoryAddingServiceProtocol {
    func addCategory(title: String) {
        let category = trackersCategoryFactory.makeCategory(title: title, isPinning: false)
        try? trackersCategoryDataAdder.add(category: category)
    }
}
