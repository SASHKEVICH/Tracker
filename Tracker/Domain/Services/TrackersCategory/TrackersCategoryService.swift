//
//  TrackersCategoryService.swift
//  Tracker
//
//  Created by Александр Бекренев on 16.06.2023.
//

import UIKit

protocol TrackersCategoryServiceProtocol {
	var numberOfSections: Int { get }
	var trackersCategoryDataProviderDelegate: TrackersCategoryDataProviderDelegate? { get set }
	func numberOfItemsInSection(_ section: Int) -> Int
	func category(at indexPath: IndexPath) -> TrackerCategory?
}

struct TrackersCategoryService {
	var numberOfSections: Int = 1
	var trackersCategoryDataProviderDelegate: TrackersCategoryDataProviderDelegate? {
		didSet {
			trackersCategoryDataProvider.delegate = trackersCategoryDataProviderDelegate
		}
	}

	private let trackersCategoryFactory = TrackersCategoryFactory()
	private var trackersCategoryDataProvider: TrackersCategoryDataProviderProtocol

	init() {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		guard let trackersCategoryDataStore = appDelegate.trackersCategoryDataStore else {
			fatalError("Cannot activate data store")
		}

		self.trackersCategoryDataProvider = TrackersCategoryDataProvider(
			context: trackersCategoryDataStore.managedObjectContext
		)
	}
}

extension TrackersCategoryService: TrackersCategoryServiceProtocol {
	func numberOfItemsInSection(_ section: Int) -> Int {
		trackersCategoryDataProvider.numberOfItemsInSection(section)
	}
	
	func category(at indexPath: IndexPath) -> TrackerCategory? {
		guard let categoryCoreData = trackersCategoryDataProvider.category(at: indexPath) else { return nil }
		return trackersCategoryFactory.makeCategory(categoryCoreData: categoryCoreData)
	}
}
