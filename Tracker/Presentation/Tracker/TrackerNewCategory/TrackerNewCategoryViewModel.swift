//
//  TrackerNewCategoryViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation

protocol TrackerNewCategoryViewModelProtocol {
	var onIsAddNewCategoryButtonDisabledChanged: Binding? { get set }
	var isAddNewCategoryButtonDisabled: Bool { get }
	func didRecieve(categoryTitle: String)
	func save(categoryTitle: String)
}

final class TrackerNewCategoryViewModel {
	var onIsAddNewCategoryButtonDisabledChanged: Binding?
	var isAddNewCategoryButtonDisabled: Bool = true {
		didSet {
			self.onIsAddNewCategoryButtonDisabledChanged?()
		}
	}

	private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol

	init(trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol) {
		self.trackersCategoryAddingService = trackersCategoryAddingService
	}
}

extension TrackerNewCategoryViewModel: TrackerNewCategoryViewModelProtocol {
	func didRecieve(categoryTitle: String) {
		let title = categoryTitle.trimmingCharacters(in: .whitespacesAndNewlines)

		if title.isEmpty {
			self.isAddNewCategoryButtonDisabled = true
		} else {
			self.isAddNewCategoryButtonDisabled = false
		}
	}

	func save(categoryTitle: String) {
		self.trackersCategoryAddingService.addCategory(title: categoryTitle)
	}
}
