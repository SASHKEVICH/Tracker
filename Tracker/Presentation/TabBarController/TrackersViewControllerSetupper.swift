//
//  TrackersViewControllerSetupper.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.07.2023.
//

import UIKit

final class TrackersViewControllerSetupper {
	private let trackersViewController = TrackersViewController()
	private let trackersCategoryService: TrackersCategoryServiceProtocol
	private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol
	private let trackersService: TrackersServiceProtocol
	private let trackersAddingService: TrackersAddingServiceProtocol
	private let trackersRecordService: TrackersRecordServiceProtocol
	private let trackersCompletingService: TrackersCompletingServiceProtocol
	private let trackersPinningService: TrackersPinningServiceProtocol
	private let alertPresenterService: AlertPresenterService
	private let analyticsService: AnalyticsServiceProtocol

	func getViewController() -> UINavigationController? {
		guard let presenter = self.preparePresenter() else { return nil }

		self.trackersViewController.presenter = presenter
		presenter.view = self.trackersViewController

		let controller = self.prepareNavigationController()
		return controller
	}

	init(
		trackersCategoryService: TrackersCategoryServiceProtocol,
		trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol,
		trackersService: TrackersServiceProtocol,
		trackersAddingService: TrackersAddingServiceProtocol,
		trackersRecordService: TrackersRecordServiceProtocol,
		trackersCompletingService: TrackersCompletingServiceProtocol,
		trackersPinningService: TrackersPinningServiceProtocol,
		alertPresenterService: AlertPresenterService,
		analyticsService: AnalyticsServiceProtocol
	) {
		self.trackersCategoryService = trackersCategoryService
		self.trackersCategoryAddingService = trackersCategoryAddingService
		self.trackersService = trackersService
		self.trackersAddingService = trackersAddingService
		self.trackersRecordService = trackersRecordService
		self.trackersCompletingService = trackersCompletingService
		self.trackersPinningService = trackersPinningService
		self.alertPresenterService = alertPresenterService
		self.analyticsService = analyticsService
	}
}

private extension TrackersViewControllerSetupper {
	func preparePresenter() -> TrackersViewPresenter? {
		guard let router = self.prepareRouter(
			trackersCategoryService: self.trackersCategoryService,
			trackersCategoryAddingService: self.trackersCategoryAddingService,
			trackersService: self.trackersService,
			trackersAddingService: self.trackersAddingService,
			trackersRecordService: self.trackersRecordService,
			trackersCompletingService: self.trackersCompletingService
		) else { return nil }

		var alertPresenterService = self.alertPresenterService
		alertPresenterService.delegate = self.trackersViewController

		let presenter = TrackersViewPresenter(
			trackersService: self.trackersService,
			trackersAddingService: self.trackersAddingService,
			trackersCompletingService: self.trackersCompletingService,
			trackersRecordService: self.trackersRecordService,
			trackersPinningService: self.trackersPinningService,
			router: router,
			alertPresenterService: alertPresenterService,
			analyticsService: self.analyticsService
		)

		var trackersService = self.trackersService
		trackersService.trackersDataProviderDelegate = presenter

		var trackersRecordService = self.trackersRecordService
		trackersRecordService.delegate = presenter

		return presenter
	}

	func prepareNavigationController() -> UINavigationController {
		let title = R.string.localizable.tabbarTracker()
		self.trackersViewController.tabBarItem = UITabBarItem(title: title, image: .TabBar.trackers, selectedImage: nil)
		let navigationController = UINavigationController(rootViewController: self.trackersViewController)
		navigationController.navigationBar.prefersLargeTitles = true
		return navigationController
	}
}

private extension TrackersViewControllerSetupper {
	func prepareRouter(
		trackersCategoryService: TrackersCategoryServiceProtocol,
		trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol,
		trackersService: TrackersServiceProtocol,
		trackersAddingService: TrackersAddingServiceProtocol,
		trackersRecordService: TrackersRecordServiceProtocol,
		trackersCompletingService: TrackersCompletingServiceProtocol
	) -> TrackersViewRouter? {
		guard let trackersService = trackersService as? TrackersServiceFilteringProtocol else { return nil }
		let router = TrackersViewRouter(
			viewController: self.trackersViewController,
			trackersCategoryService: trackersCategoryService,
			trackersCategoryAddingService: trackersCategoryAddingService,
			trackersService: trackersService,
			trackersAddingService: trackersAddingService,
			trackersRecordService: trackersRecordService,
			trackersCompletingService: trackersCompletingService
		)
		return router
	}
}
