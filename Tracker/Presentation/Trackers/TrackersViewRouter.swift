//
//  TrackersViewRouter.swift
//  Tracker
//
//  Created by Александр Бекренев on 10.07.2023.
//

import UIKit

protocol TrackersViewRouterProtocol {
	func navigateToTrackerTypeScreen()
	func navigateToFilterScreen()
}

final class TrackersViewRouter {
	private weak var viewController: UIViewController?
	private let trackersDataAdder: TrackersDataAdderProtocol
	private let trackersCategoryDataProvider: TrackersCategoryDataProviderProtocol
	private let trackersCategoryDataAdder: TrackersCategoryDataAdderProtocol

	init(
		viewController: UIViewController,
		trackersDataAdder: TrackersDataAdderProtocol,
		trackersCategoryDataProvider: TrackersCategoryDataProviderProtocol,
		trackersCategoryDataAdder: TrackersCategoryDataAdderProtocol
	) {
		self.viewController = viewController
		self.trackersDataAdder = trackersDataAdder
		self.trackersCategoryDataProvider = trackersCategoryDataProvider
		self.trackersCategoryDataAdder = trackersCategoryDataAdder
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

	func navigateToFilterScreen() {
		let trackersFactory = TrackersFactory()
		let categoryFactory = TrackersCategoryFactory(trackersFactory: trackersFactory)
		let trackersCategoryService = TrackersCategoryService(
			trackersCategoryFactory: categoryFactory,
			trackersCategoryDataProvider: self.trackersCategoryDataProvider
		)

		let viewModel = TrackerCategoryViewModel(trackersCategoryService: trackersCategoryService)
		let helper = TrackerCategoryTableViewHelper()
		let router = TrackerCategoryRouter(trackersCategoryDataAdder: self.trackersCategoryDataAdder)

		let vc = TrackerCategoryViewController(viewModel: viewModel, helper: helper, router: router, flow: .filter)
		vc.delegate = self.viewController as? TrackerCategoryViewControllerDelegate

		self.viewController?.present(vc, animated: true)
	}
}
