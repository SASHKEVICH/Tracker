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

	init(viewController: TrackerTypeViewController) {
		self.viewController = viewController
	}
}

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
		guard let addingService = TrackersAddingService(trackersFactory: TrackersFactory()) else {
			assertionFailure("Cannot init trackers adding service")
			return
		}

		let vc = TrackerAddingViewController()
		let router = TrackerAddingRouter(viewController: vc)
		let presenter = TrackerAddingViewPresenter(trackersAddingService: addingService, router: router, trackerType: trackerType)

		vc.presenter = presenter
		presenter.view = vc

		vc.emptyTap = { [weak vc] in
			vc?.view.endEditing(true)
		}

		self.viewController?.present(vc, animated: true)
	}
}
