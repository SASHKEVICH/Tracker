//
//  TrackersCategoryAddingService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation

protocol TrackersCategoryAddingServiceProtocol {
	func addCategory(title: String)
}

struct TrackersCategoryAddingService {
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
