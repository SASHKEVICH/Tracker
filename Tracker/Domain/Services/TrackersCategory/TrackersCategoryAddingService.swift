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
	private let trackersCategoryFactory: TrackersCategoryFactory

	init?(trackersCategoryFactory: TrackersCategoryFactory) {
		self.trackersCategoryFactory = trackersCategoryFactory

		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
			  let trackersCategoryDataStore = appDelegate.trackersCategoryDataStore
		else {
			assertionFailure("Cannot activate data store")
			return nil
		}

		self.trackersCategoryDataAdder = TrackersCategoryDataAdder(
			trackersCategoryDataStore: trackersCategoryDataStore,
			trackersCategoryFactory: trackersCategoryFactory
		)
	}
}

// MARK: - TrackersCategoryAddingServiceProtocol
extension TrackersCategoryAddingService: TrackersCategoryAddingServiceProtocol {
	func addCategory(title: String) {
		let category = trackersCategoryFactory.makeCategory(title: title)
		try? trackersCategoryDataAdder.add(category: category)
	}
}
