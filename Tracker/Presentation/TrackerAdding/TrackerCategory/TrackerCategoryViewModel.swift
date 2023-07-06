//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 19.06.2023.
//

import Foundation

protocol TrackerCategoryViewModelProtocol {
	var categories: [TrackerCategory] { get }
	var isPlaceholderHidden: Bool { get }
}

final class TrackerCategoryViewModel {
	@Observable
	var categories = [TrackerCategory(id: UUID(), title: "Важное", trackers: [])]
	
	@Observable
	var isPlaceholderHidden: Bool = false
}

extension TrackerCategoryViewModel: TrackerCategoryViewModelProtocol {

}
