//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 19.06.2023.
//

import Foundation

protocol TrackerCategoryViewModelProtocol {
	var onCategoriesChanged: Binding? { get set }
	var categories: [TrackerCategory] { get }

	var onIsPlaceholderHiddenChanged: Binding? { get set }
	var isPlaceholderHidden: Bool { get }
	func didChoose(category: TrackerCategory)
}

final class TrackerCategoryViewModel {
	weak var delegate: TrackerCategoryViewControllerDelegate?

	var onCategoriesChanged: Binding?
	var categories: [TrackerCategory] = [] {
		didSet {
			self.onCategoriesChanged?()
			self.shouldHidePlaceholder()
		}
	}
	
	var onIsPlaceholderHiddenChanged: Binding?
	var isPlaceholderHidden: Bool = true {
		didSet {
			self.onIsPlaceholderHiddenChanged?()
		}
	}

	private let pinnedCategoryId: UUID?

	private var trackersCategoryService: TrackersCategoryServiceProtocol

	init(trackersCategoryService: TrackersCategoryServiceProtocol, pinnedCategoryId: UUID? = nil) {
		self.trackersCategoryService = trackersCategoryService
		self.pinnedCategoryId = pinnedCategoryId
		self.trackersCategoryService.trackersCategoryDataProviderDelegate = self

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.categories = self.getCategoriesFromStore()
		}
	}
}

// MARK: - TrackerCategoryViewModelProtocol
extension TrackerCategoryViewModel: TrackerCategoryViewModelProtocol {
	func didChoose(category: TrackerCategory) {
		self.delegate?.didRecieveCategory(category)
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
		self.isPlaceholderHidden = self.categories.isEmpty == false
	}

	func getCategoriesFromStore() -> [TrackerCategory] {
		let categories = self.trackersCategoryService.categories
		return categories.filter { $0.id != self.pinnedCategoryId }
	}
}
