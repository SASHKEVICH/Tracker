//
//  TrackersCategoryService.swift
//  Tracker
//
//  Created by Александр Бекренев on 16.06.2023.
//

import Foundation

public protocol TrackersCategoryServiceProtocol {
	var numberOfSections: Int { get }
	var categories: [TrackerCategory] { get }
	var trackersCategoryDataProviderDelegate: TrackersCategoryDataProviderDelegate? { get set }
	func numberOfItemsInSection(_ section: Int) -> Int
	func category(for tracker: Tracker) -> TrackerCategory?
}

final class TrackersCategoryService {
	var numberOfSections: Int = 1
	weak var trackersCategoryDataProviderDelegate: TrackersCategoryDataProviderDelegate? {
		didSet {
			self.trackersCategoryDataProvider.delegate = self.trackersCategoryDataProviderDelegate
		}
	}

	private var trackersCategoryDataProvider: TrackersCategoryDataProviderProtocol
	private let trackersCategoryDataFetcher: TrackersCategoryDataFetcherProtocol
	private let trackersCategoryFactory: TrackersCategoryFactory

	init(
		trackersCategoryFactory: TrackersCategoryFactory,
		trackersCategoryDataProvider: TrackersCategoryDataProviderProtocol,
		trackersCategoryDataFetcher: TrackersCategoryDataFetcherProtocol
	) {
		self.trackersCategoryFactory = trackersCategoryFactory
		self.trackersCategoryDataProvider = trackersCategoryDataProvider
		self.trackersCategoryDataFetcher = trackersCategoryDataFetcher
	}
}

// MARK: - TrackersCategoryServiceProtocol
extension TrackersCategoryService: TrackersCategoryServiceProtocol {
	var categories: [TrackerCategory] {
		let categories = self.trackersCategoryDataProvider.categories
			.compactMap { trackersCategoryFactory.makeCategory(categoryCoreData: $0) }
		return categories
	}

	func numberOfItemsInSection(_ section: Int) -> Int {
		self.trackersCategoryDataProvider.numberOfItemsInSection(section)
	}

	func category(for tracker: Tracker) -> TrackerCategory? {
		guard let categoryCoreData = self.trackersCategoryDataFetcher.category(for: tracker) else { return nil }
		return self.trackersCategoryFactory.makeCategory(categoryCoreData: categoryCoreData)
	}
}
