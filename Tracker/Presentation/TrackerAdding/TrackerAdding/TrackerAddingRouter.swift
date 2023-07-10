//
//  TrackerAddingRouter.swift
//  Tracker
//
//  Created by Александр Бекренев on 10.07.2023.
//

import UIKit

protocol TrackerAddingRouterProtocol {
	func navigateToScheduleScreen(selectedWeekDays: Set<WeekDay>)
	func navigateToCategoryScreen()
}

typealias TrackerAddingViewControllerDelegate =
	UIViewController
	& TrackerCategoryViewControllerDelegate
	& TrackerScheduleViewControllerDelegate

final class TrackerAddingRouter {
	private weak var viewController: TrackerAddingViewControllerDelegate?

	init(viewController: TrackerAddingViewControllerDelegate) {
		self.viewController = viewController
	}
}

extension TrackerAddingRouter: TrackerAddingRouterProtocol {
	func navigateToScheduleScreen(selectedWeekDays: Set<WeekDay>) {
		let vc = TrackerScheduleViewController()
		vc.delegate = self.viewController

		let presenter = TrackerSchedulePresenter()
		vc.presenter = presenter
		presenter.view = vc

		presenter.selectedWeekDays = selectedWeekDays

		self.viewController?.present(vc, animated: true)
	}

	func navigateToCategoryScreen() {
		let categoryFactory = TrackersCategoryFactory(trackersFactory: TrackersFactory())
		guard let trackersCategoryService = TrackersCategoryService(trackersCategoryFactory: categoryFactory) else {
			assertionFailure("Cannot init service")
			return
		}

		let viewModel = TrackerCategoryViewModel(trackersCategoryService: trackersCategoryService)
		let helper = TrackerCategoryTableViewHelper()
		let router = TrackerCategoryRouter()

		let vc = TrackerCategoryViewController(viewModel: viewModel, helper: helper, router: router)
		vc.delegate = self.viewController

		self.viewController?.present(vc, animated: true)
	}
}
