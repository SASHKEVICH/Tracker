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
	private let trackersDataAdder: TrackersDataAdderProtocol
	private let trackersCategoryDataProvider: TrackersCategoryDataProviderProtocol
	private let trackersCategoryDataAdder: TrackersCategoryDataAdderProtocol
	private let trackersService: TrackersServiceFilteringProtocol
	private let trackersAddingService: TrackersAddingServiceProtocol
	private let trackersRecordService: TrackersRecordServiceProtocol
	private let trackersCompletingService: TrackersCompletingServiceProtocol

	init(
		viewController: UIViewController,
		trackersDataAdder: TrackersDataAdderProtocol,
		trackersCategoryDataProvider: TrackersCategoryDataProviderProtocol,
		trackersCategoryDataAdder: TrackersCategoryDataAdderProtocol,
		trackersService: TrackersServiceFilteringProtocol,
		trackersAddingService: TrackersAddingServiceProtocol,
		trackersRecordService: TrackersRecordServiceProtocol,
		trackersCompletingService: TrackersCompletingServiceProtocol
	) {
		self.viewController = viewController
		self.trackersDataAdder = trackersDataAdder
		self.trackersCategoryDataProvider = trackersCategoryDataProvider
		self.trackersCategoryDataAdder = trackersCategoryDataAdder
		self.trackersService = trackersService
		self.trackersAddingService = trackersAddingService
		self.trackersRecordService = trackersRecordService
		self.trackersCompletingService = trackersCompletingService
	}
}

// MARK: - TrackersViewRouterProtocol
extension TrackersViewRouter: TrackersViewRouterProtocol {
	func navigateToTrackerTypeScreen() {
		let vc = TrackerTypeViewController()
		let router = TrackerTypeRouter(
			viewController: vc,
			trackersDataAdder: self.trackersDataAdder,
			trackersCategoryDataProvider: self.trackersCategoryDataProvider,
			trackersCategoryDataAdder: self.trackersCategoryDataAdder
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
			trackersCategoryDataProvider: self.trackersCategoryDataProvider,
			trackersCategoryDataAdder: self.trackersCategoryDataAdder
		)

		let optionsHelper = TrackerOptionsTableViewHelper()
		let textFieldHelper = TrackerTitleTextFieldHelper()
		let colorsHelper = ColorsCollectionViewHelper()
		let emojisHelper = EmojisCollectionViewHelper()

		let viewModel = TrackerEditingViewModel(
			trackersAddingService: self.trackersAddingService,
			trackersRecordService: self.trackersRecordService,
			trackersCompletingService: self.trackersCompletingService,
			trackerType: tracker.type
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
