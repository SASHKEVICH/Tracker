//
//  TrackerCategoryRouter.swift
//  Tracker
//
//  Created by Александр Бекренев on 09.07.2023.
//

import UIKit

protocol TrackerCategoryRouterProtocol {
	func navigateToNewCategoryScreen(from viewController: TrackerCategoryViewController)
}

final class TrackerCategoryRouter {
	private let trackersCategoryDataAdder: TrackersCategoryDataAdderProtocol

	init(trackersCategoryDataAdder: TrackersCategoryDataAdderProtocol) {
		self.trackersCategoryDataAdder = trackersCategoryDataAdder
	}
}

// MARK: - TrackerCategoryRouterProtocol
extension TrackerCategoryRouter: TrackerCategoryRouterProtocol {
	func navigateToNewCategoryScreen(from viewController: TrackerCategoryViewController) {
		let trackersFactory = TrackersFactory()
		let trackersCategoryFactory = TrackersCategoryFactory(trackersFactory: trackersFactory)
		let addingService = TrackersCategoryAddingService(
			trackersCategoryFactory: trackersCategoryFactory,
			trackersCategoryDataAdder: self.trackersCategoryDataAdder
		)

		let viewModel = TrackerNewCategoryViewModel(trackersCategoryAddingService: addingService)
		let vc = TrackerNewCategoryViewController(viewModel: viewModel)

		vc.emptyTap = { [weak vc] in
			vc?.view.endEditing(true)
		}
		vc.delegate = viewController

		viewController.present(vc, animated: true)
	}
}
