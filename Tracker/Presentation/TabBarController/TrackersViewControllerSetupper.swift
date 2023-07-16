//
//  TrackersViewControllerSetupper.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.07.2023.
//

import UIKit

final class TrackersViewControllerSetupper {
	private let trackersViewController = TrackersViewController()

	private var trackersDataAdder: TrackersDataAdderProtocol?

	func getViewController() -> UINavigationController? {
		guard let presenter = self.preparePresenter() else { return nil }

		self.trackersViewController.presenter = presenter
		presenter.view = self.trackersViewController

		let controller = self.prepareNavigationController()
		return controller
	}
}

private extension TrackersViewControllerSetupper {
	func preparePresenter() -> TrackersViewPresenter? {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
			  let trackersDataStore = appDelegate.trackersDataStore,
			  let trackersCategoryDataStore = appDelegate.trackersCategoryDataStore,
			  let trackersRecordDataStore = appDelegate.trackersRecordDataStore
		else { return nil }

		let trackersFactory = TrackersFactory()
		let trackersCategoryFactory = TrackersCategoryFactory(trackersFactory: trackersFactory)

		guard let pinnedCategoryId = self.preparePinnedCategoryId(
			trackersCategoryFactory: trackersCategoryFactory,
			trackersCategoryDataStore: trackersCategoryDataStore
		) else {
			assertionFailure("Cannot get pinned category id")
			return nil
		}

		var trackersService = self.prepareTrackersService(
			trackersFactory: trackersFactory,
			trackersDataStore: trackersDataStore
		)

		let addingService = self.prepareTrackersAddingService(
			trackersFactory: trackersFactory,
			trackersDataStore: trackersDataStore,
			trackersCategoryDataStore: trackersCategoryDataStore
		)

		let pinningService = self.prepareTrackersPinningService(
			pinnedCategoryId: pinnedCategoryId,
			trackersFactory: trackersFactory,
			trackersDataStore: trackersDataStore,
			trackersCategoryDataStore: trackersCategoryDataStore
		)

		let completingService = self.prepareTrackersCompletingService(
			trackersRecordDataStore: trackersRecordDataStore,
			trackersDataStore: trackersDataStore
		)

		let recordService = self.prepareTrackersRecordService(trackersRecordDataStore: trackersRecordDataStore)

		let categoryService = self.prepareTrackersCategoryService(
			trackersCategoryFactory: trackersCategoryFactory,
			trackersCategoryDataStore: trackersCategoryDataStore
		)

		let categoryAddingService = self.prepareTrackersCategoryAddingService(
			trackersCategoryFactory: trackersCategoryFactory,
			trackersCategoryDataStore: trackersCategoryDataStore
		)

		guard let router = self.prepareRouter(
			trackersCategoryService: categoryService,
			trackersCategoryAddingService: categoryAddingService,
			trackersService: trackersService,
			trackersAddingService: addingService,
			trackersRecordService: recordService,
			trackersCompletingService: completingService
		) else { return nil }

		var alertPresenterService = AlertPresenterService()
		alertPresenterService.delegate = self.trackersViewController

		let analyticsService = AnalyticsService()

		let presenter = TrackersViewPresenter(
			trackersService: trackersService,
			trackersAddingService: addingService,
			trackersCompletingService: completingService,
			trackersRecordService: recordService,
			trackersPinningService: pinningService,
			router: router,
			alertPresenterService: alertPresenterService,
			analyticsService: analyticsService
		)

		trackersService.trackersDataProviderDelegate = presenter
		recordService.delegate = presenter

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
	func prepareTrackersService(
		trackersFactory: TrackersFactory,
		trackersDataStore: TrackersDataStore
	) -> TrackersService {
		let provider = TrackersDataProvider(context: trackersDataStore.managedObjectContext)
		let service = TrackersService(trackersFactory: trackersFactory, trackersDataProvider: provider)
		return service
	}

	func prepareTrackersAddingService(
		trackersFactory: TrackersFactory,
		trackersDataStore: TrackersDataStore,
		trackersCategoryDataStore: TrackersCategoryDataStore
	) -> TrackersAddingService {
		let adder = TrackersDataAdder(
			trackersCategoryDataStore: trackersCategoryDataStore,
			trackersDataStore: trackersDataStore,
			trackersFactory: trackersFactory
		)
		self.trackersDataAdder = adder
		let trackersAddingService = TrackersAddingService(trackersFactory: trackersFactory, trackersDataAdder: adder)
		return trackersAddingService
	}

	func prepareTrackersCompletingService(
		trackersRecordDataStore: TrackersRecordDataStore,
		trackersDataStore: TrackersDataStore
	) -> TrackersCompletingService {
		let completer = TrackersDataCompleter(
			trackersRecordDataStore: trackersRecordDataStore,
			trackersDataStore: trackersDataStore
		)
		let service = TrackersCompletingService(trackersDataCompleter: completer)
		return service
	}

	func prepareTrackersRecordService(trackersRecordDataStore: TrackersRecordDataStore) -> TrackersRecordService {
		let fetcher = TrackersRecordDataFetcher(trackersRecordDataStore: trackersRecordDataStore)
		let service = TrackersRecordService(trackersRecordDataFetcher: fetcher)
		return service
	}

	func prepareTrackersPinningService(
		pinnedCategoryId: UUID,
		trackersFactory: TrackersFactory,
		trackersDataStore: TrackersDataStore,
		trackersCategoryDataStore: TrackersCategoryDataStore
	) -> TrackersPinningService {
		let pinner = TrackersDataPinner(
			pinnedCategoryId: pinnedCategoryId,
			trackersDataStore: trackersDataStore,
			trackersCategoryDataStore: trackersCategoryDataStore
		)

		let service = TrackersPinningService(trackersFactory: trackersFactory, trackersDataPinner: pinner)
		return service
	}

	func prepareTrackersCategoryService(
		trackersCategoryFactory: TrackersCategoryFactory,
		trackersCategoryDataStore: TrackersCategoryDataStore
	) -> TrackersCategoryService {
		let provider = TrackersCategoryDataProvider(context: trackersCategoryDataStore.managedObjectContext)
		let fetcher = TrackersCategoryDataFetcher(trackersCategoryDataStore: trackersCategoryDataStore)

		let service = TrackersCategoryService(
			trackersCategoryFactory: trackersCategoryFactory,
			trackersCategoryDataProvider: provider,
			trackersCategoryDataFetcher: fetcher
		)

		return service
	}

	func prepareTrackersCategoryAddingService(
		trackersCategoryFactory: TrackersCategoryFactory,
		trackersCategoryDataStore: TrackersCategoryDataStore
	) -> TrackersCategoryAddingService {
		let adder = TrackersCategoryDataAdder(
			trackersCategoryDataStore: trackersCategoryDataStore,
			trackersCategoryFactory: trackersCategoryFactory
		)

		let service = TrackersCategoryAddingService(
			trackersCategoryFactory: trackersCategoryFactory,
			trackersCategoryDataAdder: adder
		)

		return service
	}

	func prepareRouter(
		trackersCategoryService: TrackersCategoryServiceProtocol,
		trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol,
		trackersService: TrackersServiceFilteringProtocol,
		trackersAddingService: TrackersAddingServiceProtocol,
		trackersRecordService: TrackersRecordServiceProtocol,
		trackersCompletingService: TrackersCompletingService
	) -> TrackersViewRouter? {
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

	func preparePinnedCategoryId(
		trackersCategoryFactory: TrackersCategoryFactory,
		trackersCategoryDataStore: TrackersCategoryDataStore
	) -> UUID? {
		let pinnedCategoryService = TrackersPinnedCategoryService(
			trackersCategoryFactory: trackersCategoryFactory,
			trackersCategoryDataStore: trackersCategoryDataStore
		)
		pinnedCategoryService?.checkPinnedCategory()
		return pinnedCategoryService?.pinnedCategoryId
	}
}
