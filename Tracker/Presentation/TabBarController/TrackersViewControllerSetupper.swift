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

		let completingService = self.prepareTrackersCompletingService(trackersRecordDataStore: trackersRecordDataStore)
		let recordService = self.prepareTrackersRecordService(trackersRecordDataStore: trackersRecordDataStore)

		guard let router = self.prepareRouter(
			trackersDataStore: trackersDataStore,
			trackersCategoryDataStore: trackersCategoryDataStore,
			trackersCategoryFactory: trackersCategoryFactory,
			trackersService: trackersService
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

	func prepareTrackersCompletingService(trackersRecordDataStore: TrackersRecordDataStore) -> TrackersCompletingService {
		let completer = TrackersDataCompleter(trackerRecordDataStore: trackersRecordDataStore)
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

	func prepareRouter(
		trackersDataStore: TrackersDataStore,
		trackersCategoryDataStore: TrackersCategoryDataStore,
		trackersCategoryFactory: TrackersCategoryFactory,
		trackersService: TrackersServiceFilteringProtocol
	) -> TrackersViewRouter? {
		guard let adder = self.trackersDataAdder else { return nil }

		let categoryDataProvider = TrackersCategoryDataProvider(context: trackersDataStore.managedObjectContext)
		let categoryDataAdder = TrackersCategoryDataAdder(
			trackersCategoryDataStore: trackersCategoryDataStore,
			trackersCategoryFactory: trackersCategoryFactory
		)
		let router = TrackersViewRouter(
			viewController: self.trackersViewController,
			trackersDataAdder: adder,
			trackersCategoryDataProvider: categoryDataProvider,
			trackersCategoryDataAdder: categoryDataAdder,
			trackersService: trackersService
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
