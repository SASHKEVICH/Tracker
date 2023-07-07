//
//  TrackersCategoryAddingService.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import UIKit

protocol TrackersCategoryAddingServiceProtocol {
	func addCategory(title: String)
}

struct TrackersCategoryAddingService {
	private let trackersCategoryDataAdder: TrackersCategoryDataAdderProtocol
	private let trackersCategoryFactory = TrackersCategoryFactory()

	init() {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		guard let trackersCategoryDataStore = appDelegate.trackersCategoryDataStore else {
			fatalError("Cannot activate data store")
		}
		self.trackersCategoryDataAdder = TrackersCategoryDataAdder(trackersCategoryDataStore: trackersCategoryDataStore)
	}
}

// MARK: - TrackersCategoryAddingServiceProtocol
extension TrackersCategoryAddingService: TrackersCategoryAddingServiceProtocol {
	func addCategory(title: String) {
		let category = trackersCategoryFactory.makeCategory(title: title)
		try? trackersCategoryDataAdder.add(category: category)
	}
}
