//
//  TrackerAddingRouter.swift
//  Tracker
//
//  Created by Александр Бекренев on 10.07.2023.
//

import UIKit

protocol TrackerAddingRouterProtocol {
	func navigateToScheduleScreen(selectedWeekDays: Set<WeekDay>)
	func navigateToCategoryScreen(selectedCategory: TrackerCategory?)
	func navigateToMainScreen()
}

final class TrackerAddingRouter {
	private weak var viewController: UIViewController?
	private let trackersCategoryDataProvider: TrackersCategoryDataProviderProtocol
	private let trackersCategoryDataAdder: TrackersCategoryDataAdderProtocol

	init(
		viewController: UIViewController,
		trackersCategoryDataProvider: TrackersCategoryDataProviderProtocol,
		trackersCategoryDataAdder: TrackersCategoryDataAdderProtocol
	) {
		self.viewController = viewController
		self.trackersCategoryDataProvider = trackersCategoryDataProvider
		self.trackersCategoryDataAdder = trackersCategoryDataAdder
	}
}

extension TrackerAddingRouter: TrackerAddingRouterProtocol {
	func navigateToScheduleScreen(selectedWeekDays: Set<WeekDay>) {
		let vc = TrackerScheduleViewController()
		vc.delegate = self.viewController as? TrackerScheduleViewControllerDelegate

		let presenter = TrackerSchedulePresenter()
		vc.presenter = presenter
		presenter.view = vc

		presenter.selectedWeekDays = selectedWeekDays

		self.viewController?.present(vc, animated: true)
	}

	func navigateToCategoryScreen(selectedCategory: TrackerCategory?) {
		let trackersFactory = TrackersFactory()
		let categoryFactory = TrackersCategoryFactory(trackersFactory: trackersFactory)
		let trackersCategoryService = TrackersCategoryService(
			trackersCategoryFactory: categoryFactory,
			trackersCategoryDataProvider: self.trackersCategoryDataProvider
		)

		let viewModel = TrackerCategoryViewModel(trackersCategoryService: trackersCategoryService)
		viewModel.delegate = self.viewController as? TrackerCategoryViewControllerDelegate

		let helper = TrackerCategoryTableViewHelper()
		let router = TrackerCategoryRouter(trackersCategoryDataAdder: self.trackersCategoryDataAdder)

		let vc = TrackerCategoryViewController(
			viewModel: viewModel,
			helper: helper,
			router: router,
			flow: .normal,
			selectedCategory: selectedCategory
		)

		self.viewController?.present(vc, animated: true)
	}

	func navigateToMainScreen() {
		UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
	}
}
