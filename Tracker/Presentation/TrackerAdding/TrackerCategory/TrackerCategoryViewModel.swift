//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 19.06.2023.
//

import Foundation

protocol TrackerCategoryViewModelProtocol {
	var onCategoriesChanged: (() -> Void)? { get set }
	var categories: [TrackerCategory] { get }

	var onIsPlaceholderHiddenChanged: (() -> Void)? { get set }
	var isPlaceholderHidden: Bool { get }
	func addNewCategory()
}

final class TrackerCategoryViewModel {
	var onCategoriesChanged: (() -> Void)?
	var categories: [TrackerCategory] = [] {
		didSet {
			self.onCategoriesChanged?()
			self.shouldHidePlaceholder()
		}
	}
	
	var onIsPlaceholderHiddenChanged: (() -> Void)?
	var isPlaceholderHidden: Bool = true {
		didSet {
			self.onIsPlaceholderHiddenChanged?()
		}
	}

	private var trackersCategoryService: TrackersCategoryServiceProtocol

	init(trackersCategoryService: TrackersCategoryServiceProtocol) {
		self.trackersCategoryService = trackersCategoryService
		self.trackersCategoryService.trackersCategoryDataProviderDelegate = self

		self.categories = self.getCategoriesFromStore()
	}
}

// MARK: - TrackerCategoryViewModelProtocol
extension TrackerCategoryViewModel: TrackerCategoryViewModelProtocol {
	func addNewCategory() {
		categories.append(TrackerCategory(id: UUID(), title: "Очень важное", trackers: []))
	}
}

// MARK: - TrackersCategoryDataProviderDelegate
extension TrackerCategoryViewModel: TrackersCategoryDataProviderDelegate {
	func storeDidUpdate() {
		self.categories = self.getCategoriesFromStore()
	}
}

private extension TrackerCategoryViewModel {
	func shouldHidePlaceholder() {
		self.isPlaceholderHidden = self.categories.isEmpty
	}

	func getCategoriesFromStore() -> [TrackerCategory] {
		self.trackersCategoryService.categories
	}
}
