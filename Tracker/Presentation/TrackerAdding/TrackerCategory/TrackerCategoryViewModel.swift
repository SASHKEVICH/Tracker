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
	var categories = [
		TrackerCategory(id: UUID(), title: "Важное", trackers: []),
		TrackerCategory(id: UUID(), title: "Не важное", trackers: [])
	] {
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
}

extension TrackerCategoryViewModel: TrackerCategoryViewModelProtocol {
	func addNewCategory() {
		categories.append(TrackerCategory(id: UUID(), title: "Очень важное", trackers: []))
	}
}

private extension TrackerCategoryViewModel {
	func shouldHidePlaceholder() {
		if self.categories.isEmpty {
			self.isPlaceholderHidden = false
		}
	}
}
