//
//  TrackerAddingRouter.swift
//  Tracker
//
//  Created by Александр Бекренев on 10.07.2023.
//

import UIKit

protocol TrackerAddingRouterProtocol {
	func navigateToScheduleScreen(selectedWeekDays: Set<WeekDay>, from viewController: UIViewController)
	func navigateToCategoryScreen(selectedCategory: TrackerCategory?, from viewController: UIViewController)
	func navigateToMainScreen()
}

final class TrackerAddingRouter {
	private let trackersCategoryService: TrackersCategoryServiceProtocol
	private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol

	init(
		trackersCategoryService: TrackersCategoryServiceProtocol,
		trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol
	) {
		self.trackersCategoryService = trackersCategoryService
		self.trackersCategoryAddingService = trackersCategoryAddingService
	}
}

extension TrackerAddingRouter: TrackerAddingRouterProtocol {
	func navigateToScheduleScreen(selectedWeekDays: Set<WeekDay>, from viewController: UIViewController) {
		let vc = TrackerScheduleViewController()
		vc.delegate = viewController as? TrackerScheduleViewControllerDelegate

		let presenter = TrackerSchedulePresenter()
		vc.presenter = presenter
		presenter.view = vc

		presenter.selectedWeekDays = selectedWeekDays

		viewController.present(vc, animated: true)
	}

	func navigateToCategoryScreen(selectedCategory: TrackerCategory?, from viewController: UIViewController) {
		let viewModel = TrackerCategoryViewModel(trackersCategoryService: self.trackersCategoryService)
		viewModel.delegate = viewController as? TrackerCategoryViewControllerDelegate

		let helper = TrackerCategoryTableViewHelper()
		let router = TrackerCategoryRouter(trackersCategoryAddingService: self.trackersCategoryAddingService)

		let vc = TrackerCategoryViewController(
			viewModel: viewModel,
			helper: helper,
			router: router,
			flow: .normal,
			selectedCategory: selectedCategory
		)

		viewController.present(vc, animated: true)
	}

	func navigateToMainScreen() {
		UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
	}
}