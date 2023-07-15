//
//  TrackerFilterViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.07.2023.
//

import Foundation

protocol TrackerFilterViewControllerDelegate: AnyObject {
	func setCurrentDate()
}

final class TrackerFilterViewModel {
	enum FilterMode: Equatable {
		case all(Date)
		case today
		case completed(Date)
		case incompleted(Date)

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

	weak var delegate: TrackerFilterViewControllerDelegate?

	var onCategoriesChanged: (() -> Void)?
	var categories: [TrackerCategory] {
		let allTrackers = self.prepareFilter(for: .all(self.chosenDate))
		let todayTrackers = self.prepareFilter(for: .today)
		let completedTrackers = self.prepareFilter(for: .completed(self.chosenDate))
		let incompletedTrackers = self.prepareFilter(for: .incompleted(self.chosenDate))

		return [allTrackers, todayTrackers, completedTrackers, incompletedTrackers]
	}

	var onIsPlaceholderHiddenChanged: (() -> Void)?
	var isPlaceholderHidden: Bool { true }

	private let trackersCategoryFactory: TrackersCategoryFactory
	private let trackersService: TrackersServiceFilteringProtocol
	private let chosenDate: Date

	init(
		chosenDate: Date,
		trackersCategoryFactory: TrackersCategoryFactory,
		trackersService: TrackersServiceFilteringProtocol
	) {
		self.chosenDate = chosenDate
		self.trackersCategoryFactory = trackersCategoryFactory
		self.trackersService = trackersService
	}
}

// MARK: - TrackerCategoryViewModelProtocol
extension TrackerFilterViewModel: TrackerCategoryViewModelProtocol {
	func didChoose(category: TrackerCategory) {
		guard let mode = self.resolveFiltrationMode(for: category.title) else { return }
		if mode == .today {
			self.delegate?.setCurrentDate()
		}

		self.trackersService.performFiltering(mode: mode)
	}
}

private extension TrackerFilterViewModel {
	func prepareFilter(for mode: FilterMode) -> TrackerCategory {
		self.trackersCategoryFactory.makeCategory(title: mode.localized, isPinning: false)
	}

	func resolveFiltrationMode(for title: String) -> FilterMode? {
		switch title {
		case FilterMode.all(self.chosenDate).localized:
			return .all(self.chosenDate)
		case FilterMode.today.localized:
			return .today
		case FilterMode.completed(self.chosenDate).localized:
			return .completed(self.chosenDate)
		case FilterMode.incompleted(self.chosenDate).localized:
			return .incompleted(self.chosenDate)
		default:
			return nil
		}
	}
}
