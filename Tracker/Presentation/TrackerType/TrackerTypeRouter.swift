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
	private let trackersDataAdder: TrackersDataAdderProtocol
	private let trackersCategoryDataProvider: TrackersCategoryDataProviderProtocol
	private let trackersCategoryDataAdder: TrackersCategoryDataAdderProtocol

	init(
		viewController: TrackerTypeViewController,
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
		let factory = TrackersFactory()
		let addingService = TrackersAddingService(trackersFactory: factory, trackersDataAdder: self.trackersDataAdder)

		let router = TrackerAddingRouter(
			trackersCategoryDataProvider: self.trackersCategoryDataProvider,
			trackersCategoryDataAdder: self.trackersCategoryDataAdder
		)

		let viewModel = TrackerAddingViewModel(trackersAddingService: addingService, trackerType: trackerType)

		let optionsHelper = TrackerOptionsTableViewHelper()
		let textFieldHelper = TrackerTitleTextFieldHelper()
		let colorsHelper = ColorsCollectionViewHelper()
		let emojisHelper = EmojisCollectionViewHelper()

		let vc = TrackerAddingViewController(
			viewModel: viewModel,
			router: router,
			optionsTableViewHelper: optionsHelper,
			titleTextFieldHelper: textFieldHelper,
			colorsHelper: colorsHelper,
			emojisHelper: emojisHelper,
			flow: .add
		)

		optionsHelper.delegate = vc
		colorsHelper.delegate = vc
		emojisHelper.delegate = vc

		vc.emptyTap = { [weak vc] in
			vc?.view.endEditing(true)
		}

		self.viewController?.present(vc, animated: true)
	}
}
