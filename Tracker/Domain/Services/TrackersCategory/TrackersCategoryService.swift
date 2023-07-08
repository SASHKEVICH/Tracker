//
//  TrackersCategoryService.swift
//  Tracker
//
//  Created by Александр Бекренев on 16.06.2023.
//

import UIKit

protocol TrackersCategoryServiceProtocol {
	var numberOfSections: Int { get }
	var categories: [TrackerCategory] { get }
	var trackersCategoryDataProviderDelegate: TrackersCategoryDataProviderDelegate? { get set }
	func numberOfItemsInSection(_ section: Int) -> Int
}

struct TrackersCategoryService {
	var numberOfSections: Int = 1
	var trackersCategoryDataProviderDelegate: TrackersCategoryDataProviderDelegate? {
		didSet {
			trackersCategoryDataProvider.delegate = trackersCategoryDataProviderDelegate
		}
	}

	private var trackersCategoryDataProvider: TrackersCategoryDataProviderProtocol
	private let trackersCategoryFactory: TrackersCategoryFactory

	init?(trackersCategoryFactory: TrackersCategoryFactory) {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
			  let trackersCategoryDataStore = appDelegate.trackersCategoryDataStore
		else {
			assertionFailure("Cannot activate data store")
			return nil
		}

		self.trackersCategoryFactory = trackersCategoryFactory
		self.trackersCategoryDataProvider = TrackersCategoryDataProvider(
			context: trackersCategoryDataStore.managedObjectContext
		)
	}
}

extension TrackersCategoryService: TrackersCategoryServiceProtocol {
	var categories: [TrackerCategory] {
		let categories = self.trackersCategoryDataProvider.categories
			.compactMap { trackersCategoryFactory.makeCategory(categoryCoreData: $0) }
		return categories
	}

	func numberOfItemsInSection(_ section: Int) -> Int {
		self.trackersCategoryDataProvider.numberOfItemsInSection(section)
	}
}
