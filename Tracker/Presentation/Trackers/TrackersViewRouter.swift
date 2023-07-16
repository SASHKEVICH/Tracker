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

	init(
		viewController: UIViewController,
		trackersDataAdder: TrackersDataAdderProtocol,
		trackersCategoryDataProvider: TrackersCategoryDataProviderProtocol,
		trackersCategoryDataAdder: TrackersCategoryDataAdderProtocol,
		trackersService: TrackersServiceFilteringProtocol,
		trackersAddingService: TrackersAddingServiceProtocol
	) {
		self.viewController = viewController
		self.trackersDataAdder = trackersDataAdder
		self.trackersCategoryDataProvider = trackersCategoryDataProvider
		self.trackersCategoryDataAdder = trackersCategoryDataAdder
		self.trackersService = trackersService
		self.trackersAddingService = trackersAddingService
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
		let vc = TrackerAddingViewController()
		let router = TrackerAddingRouter(
			viewController: vc,
			trackersCategoryDataProvider: self.trackersCategoryDataProvider,
			trackersCategoryDataAdder: self.trackersCategoryDataAdder
		)

		let presenter = TrackerAddingViewPresenter(
			trackersAddingService: self.trackersAddingService,
			router: router,
			trackerType: tracker.type,
			flow: .edit(tracker)
		)

		vc.presenter = presenter
		presenter.view = vc

		vc.emptyTap = { [weak vc] in
			vc?.view.endEditing(true)
		}

		self.viewController?.present(vc, animated: true)
	}
}
