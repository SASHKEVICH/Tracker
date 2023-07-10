//
//  TrackerTypePresenter.swift
//  Tracker
//
//  Created by Александр Бекренев on 10.07.2023.
//

import Foundation

protocol TrackerTypePresenterProtocol {
	func navigateToTrackerScreen()
	func navigateToIrregularEventScreen()
}

final class TrackerTypePresenter {
	private let router: TrackerTypeRouterProtocol

	init(router: TrackerTypeRouterProtocol) {
		self.router = router
	}
}

// MARK: - TrackerTypePresenterProtocol
extension TrackerTypePresenter: TrackerTypePresenterProtocol {
	func navigateToTrackerScreen() {
		self.router.navigateToTrackerScreen()
	}

	func navigateToIrregularEventScreen() {
		self.router.navigateToIrregularEventScreen()
	}
}
