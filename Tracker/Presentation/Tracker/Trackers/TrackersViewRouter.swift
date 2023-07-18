//
//  TrackersViewRouter.swift
//  Tracker
//
//  Created by Александр Бекренев on 10.07.2023.
//

import UIKit

protocol TrackersViewRouterProtocol {
	func navigateToTrackerTypeScreen()
	func navigateToFilterScreen(chosenDate: Date, selectedFilter: TrackerCategory?)
	func navigateToEditTrackerScreen(tracker: Tracker)
}

final class TrackersViewRouter {
	private weak var viewController: UIViewController?
	private let trackersCategoryService: TrackersCategoryServiceProtocol
	private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol
	private let trackersService: TrackersServiceFilteringProtocol
	private let trackersAddingService: TrackersAddingServiceProtocol
	private let trackersRecordService: TrackersRecordServiceProtocol
	private let trackersCompletingService: TrackersCompletingServiceProtocol
	private let pinnedCategoryId: UUID

	init(
		viewController: UIViewController,
		trackersCategoryService: TrackersCategoryServiceProtocol,
		trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol,
		trackersService: TrackersServiceFilteringProtocol,
		trackersAddingService: TrackersAddingServiceProtocol,
		trackersRecordService: TrackersRecordServiceProtocol,
		trackersCompletingService: TrackersCompletingServiceProtocol,
		pinnedCategoryId: UUID
	) {
		self.viewController = viewController
		self.trackersCategoryService = trackersCategoryService
		self.trackersCategoryAddingService = trackersCategoryAddingService
		self.trackersService = trackersService
		self.trackersAddingService = trackersAddingService
		self.trackersRecordService = trackersRecordService
		self.trackersCompletingService = trackersCompletingService
		self.pinnedCategoryId = pinnedCategoryId
	}
}

// MARK: - TrackersViewRouterProtocol
extension TrackersViewRouter: TrackersViewRouterProtocol {
	func navigateToTrackerTypeScreen() {
		let vc = TrackerTypeViewController()
		let router = TrackerTypeRouter(
			viewController: vc,
			trackersAddingService: self.trackersAddingService,
			trackersCategoryService: self.trackersCategoryService,
			trackersCategoryAddingService: self.trackersCategoryAddingService,
			pinnedCategoryId: self.pinnedCategoryId
		)
		let presenter = TrackerTypePresenter(router: router)

		vc.presenter = presenter

		self.viewController?.present(vc, animated: true)
	}

	func navigateToFilterScreen(chosenDate: Date, selectedFilter: TrackerCategory?) {
		let trackersFactory = TrackersFactory()
		let categoryFactory = TrackersCategoryFactory(trackersFactory: trackersFactory)

		let viewModel = TrackerFilterViewModel(
			chosenDate: chosenDate,
			trackersCategoryFactory: categoryFactory,
			trackersService: self.trackersService
		)
		viewModel.delegate = self.viewController as? TrackerFilterViewControllerDelegate

		let helper = TrackerCategoryTableViewHelper()
		let vc = TrackerCategoryViewController(
			viewModel: viewModel,
			helper: helper,
			router: nil,
			flow: .filter,
			selectedCategory: selectedFilter
		)

		self.viewController?.present(vc, animated: true)
	}

	func navigateToEditTrackerScreen(tracker: Tracker) {
		let router = TrackerAddingRouter(
			trackersCategoryService: self.trackersCategoryService,
			trackersCategoryAddingService: self.trackersCategoryAddingService
		)

		let optionsHelper = TrackerOptionsTableViewHelper()
		let textFieldHelper = TrackerTitleTextFieldHelper()
		let colorsHelper = ColorsCollectionViewHelper()
		let emojisHelper = EmojisCollectionViewHelper()

		let viewModel = TrackerEditingViewModel(
			trackersAddingService: self.trackersAddingService,
			trackersRecordService: self.trackersRecordService,
			trackersCompletingService: self.trackersCompletingService,
			trackersCategoryService: trackersCategoryService,
			tracker: tracker
		)

		let view = TrackerAddingView(
			optionsTableViewHelper: optionsHelper,
			titleTextFieldHelper: textFieldHelper,
			colorsHelper: colorsHelper,
			emojisHelper: emojisHelper,
			flow: .edit
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
