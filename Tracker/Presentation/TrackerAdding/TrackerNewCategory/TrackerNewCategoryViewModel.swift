//
//  TrackerNewCategoryViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation

protocol TrackerNewCategoryViewModelProtocol {
	var onIsAddNewCategoryButtonDisabledChanged: (() -> Void)? { get set }
	var isAddNewCategoryButtonDisabled: Bool { get }
	func didRecieve(categoryTitle: String)
	func save(categoryTitle: String)
}

final class TrackerNewCategoryViewModel {
	var onIsAddNewCategoryButtonDisabledChanged: (() -> Void)?
	var isAddNewCategoryButtonDisabled: Bool = true {
		didSet {
			self.onIsAddNewCategoryButtonDisabledChanged?()
		}
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
		print(#function)
	}
}
