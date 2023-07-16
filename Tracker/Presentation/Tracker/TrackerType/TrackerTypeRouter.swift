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

	init(
		viewController: TrackerTypeViewController,
		trackersAddingService: TrackersAddingServiceProtocol,
		trackersCategoryService: TrackersCategoryServiceProtocol,
		trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol
	) {
		self.viewController = viewController
		self.trackersAddingService = trackersAddingService
		self.trackersCategoryService = trackersCategoryService
		self.trackersCategoryAddingService = trackersCategoryAddingService
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
			trackersCategoryAddingService: self.trackersCategoryAddingService
		)

		let viewModel = TrackerAddingViewModel(trackersAddingService: self.trackersAddingService, trackerType: trackerType)
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
