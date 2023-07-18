//
//  TrackerTypeRouter.swift
//  Tracker
//
//  Created by Александр Бекренев on 10.07.2023.
//

import Foundation

protocol TrackerTypeRouterProtocol {
	func navigateToTrackerScreen()
	func navigateToIrregularEventScreen()
}

final class TrackerTypeRouter {
	private weak var viewController: TrackerTypeViewController?
	private let trackersAddingService: TrackersAddingServiceProtocol
	private let trackersCategoryService: TrackersCategoryServiceProtocol
	private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol
	private let pinnedCategoryId: UUID?

	init(
		viewController: TrackerTypeViewController,
		trackersAddingService: TrackersAddingServiceProtocol,
		trackersCategoryService: TrackersCategoryServiceProtocol,
		trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol,
		pinnedCategoryId: UUID?

	) {
		self.viewController = viewController
		self.trackersAddingService = trackersAddingService
		self.trackersCategoryService = trackersCategoryService
		self.trackersCategoryAddingService = trackersCategoryAddingService
		self.pinnedCategoryId = pinnedCategoryId
	}
}

// MARK: - TrackerTypeRouterProtocol
extension TrackerTypeRouter: TrackerTypeRouterProtocol {
	func navigateToTrackerScreen() {
		self.presentAddingViewController(trackerType: .tracker)
	}

	func navigateToIrregularEventScreen() {
		self.presentAddingViewController(trackerType: .irregularEvent)
	}
}

private extension TrackerTypeRouter {
	func presentAddingViewController(trackerType: Tracker.TrackerType) {
		let optionsHelper = TrackerOptionsTableViewHelper()
		let textFieldHelper = TrackerTitleTextFieldHelper()
		let colorsHelper = ColorsCollectionViewHelper()
		let emojisHelper = EmojisCollectionViewHelper()

		let view = TrackerAddingView(
			optionsTableViewHelper: optionsHelper,
			titleTextFieldHelper: textFieldHelper,
			colorsHelper: colorsHelper,
			emojisHelper: emojisHelper,
			flow: .add
		)

		let router = TrackerAddingRouter(
			trackersCategoryService: self.trackersCategoryService,
			trackersCategoryAddingService: self.trackersCategoryAddingService,
			pinnedCategoryId: self.pinnedCategoryId
		)

		let optionsTitle = self.prepareOptionsTitles(for: trackerType)
		let viewControllerTitle = self.prepareAddingViewControllerTitle(for: trackerType)

		let viewModel = TrackerAddingViewModel(
			trackersAddingService: self.trackersAddingService,
			trackerType: trackerType,
			optionTitles: optionsTitle,
			viewControllerTitle: viewControllerTitle
		)
		
		let vc = TrackerAddingViewController(viewModel: viewModel, router: router, view: view)

		optionsHelper.delegate = vc
		colorsHelper.delegate = vc
		emojisHelper.delegate = vc

		vc.emptyTap = { [weak vc] in
			vc?.view.endEditing(true)
		}

		self.viewController?.present(vc, animated: true)
	}
}

private extension TrackerTypeRouter {
	func prepareOptionsTitles(for type: Tracker.TrackerType) -> [String] {
		let localizable = R.string.localizable
		let categoryTitle = localizable.trackerAddingOptionTitleCategory()
		switch type {
		case .tracker:
			let scheduleTitle = localizable.trackerAddingOptionTitleSchedule()
			return [categoryTitle, scheduleTitle]
		case .irregularEvent:
			return [categoryTitle]
		}
	}

	func prepareAddingViewControllerTitle(for type: Tracker.TrackerType) -> String {
		let localizable = R.string.localizable
		switch type {
		case .tracker:
			return localizable.trackerAddingTrackerViewControllerTitle()
		case .irregularEvent:
			return localizable.trackerAddingIrregularEventViewControllerTitle()
		}
	}
}
