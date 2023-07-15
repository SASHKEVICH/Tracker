//
//  TrackerFilterViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.07.2023.
//

import Foundation

struct TrackerFilterViewModel {
	enum FilterMode {
		case all
		case today
		case completed
		case incompleted

		var localized: String {
			let localizable = R.string.localizable
			switch self {
			case .all: return localizable.trackerCategoryFlowFilterModeAll()
			case .today: return localizable.trackerCategoryFlowFilterModeToday()
			case .completed: return localizable.trackerCategoryFlowFilterModeCompleted()
			case .incompleted: return localizable.trackerCategoryFlowFilterModeIncompleted()
			}
		}
	}

	var onCategoriesChanged: (() -> Void)?
	var categories: [TrackerCategory] {
		let allTrackers = self.prepareFilter(for: .all)
		let todayTrackers = self.prepareFilter(for: .today)
		let completedTrackers = self.prepareFilter(for: .completed)
		let incompletedTrackers = self.prepareFilter(for: .incompleted)

		return [allTrackers, todayTrackers, completedTrackers, incompletedTrackers]
	}

	var onIsPlaceholderHiddenChanged: (() -> Void)?
	var isPlaceholderHidden: Bool { true }

	private let trackersCategoryFactory: TrackersCategoryFactory
	private let trackersService: TrackersServiceFilteringProtocol

	init(trackersCategoryFactory: TrackersCategoryFactory, trackersService: TrackersServiceFilteringProtocol) {
		self.trackersCategoryFactory = trackersCategoryFactory
		self.trackersService = trackersService
	}
}

// MARK: - TrackerCategoryViewModelProtocol
extension TrackerFilterViewModel: TrackerCategoryViewModelProtocol {
	func didChoose(category: TrackerCategory) {
		guard let mode = self.resolveFiltrationMode(for: category.title) else { return }
		print(mode)
//		self.trackersService.performFiltering(mode: mode)
	}
}

private extension TrackerFilterViewModel {
	func prepareFilter(for mode: FilterMode) -> TrackerCategory {
		self.trackersCategoryFactory.makeCategory(title: mode.localized, isPinning: false)
	}

	func resolveFiltrationMode(for title: String) -> FilterMode? {
		switch title {
		case FilterMode.all.localized:
			return .all
		case FilterMode.today.localized:
			return .today
		case FilterMode.completed.localized:
			return .completed
		case FilterMode.incompleted.localized:
			return .incompleted
		default:
			return nil
		}
	}
}
