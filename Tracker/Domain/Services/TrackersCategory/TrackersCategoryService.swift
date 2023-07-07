//
//  TrackersCategoryService.swift
//  Tracker
//
//  Created by Александр Бекренев on 16.06.2023.
//

import Foundation

protocol TrackersCategoryServiceProtocol {
	var numberOfSections: Int { get }
	var trackersDataProviderDelegate: TrackersDataProviderDelegate? { get set }
	func numberOfItemsInSection(_ section: Int) -> Int
	func category(at indexPath: IndexPath) -> TrackerCategory?
	func fetchCategories()
}

struct TrackersCategoryService {
	var numberOfSections: Int = 1
	var trackersDataProviderDelegate: TrackersDataProviderDelegate?
}

extension TrackersCategoryService: TrackersCategoryServiceProtocol {
	func numberOfItemsInSection(_ section: Int) -> Int {
		0
	}
	
	func category(at indexPath: IndexPath) -> TrackerCategory? {
		TrackerCategory(id: UUID(), title: "Важное", trackers: [])
	}
	
	func fetchCategories() {

	}
}
