//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 31.03.2023.
//

import UIKit

final class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

		guard let serviceSetupper = self.prepareServiceSetupper() else { return }

		let trackersSetupper = TrackersViewControllerSetupper(
			trackersCategoryService: serviceSetupper.trackersCategoryService,
			trackersCategoryAddingService: serviceSetupper.trackersCategoryAddingService,
			trackersService: serviceSetupper.trackersService,
			trackersAddingService: serviceSetupper.trackersAddingService,
			trackersRecordService: serviceSetupper.trackersRecordService,
			trackersCompletingService: serviceSetupper.trackersCompletingService,
			trackersPinningService: serviceSetupper.trackersPinningService,
			alertPresenterService: serviceSetupper.alertPresenterService,
			analyticsService: serviceSetupper.analyticsService
		)

		guard let trackersViewController = trackersSetupper.getViewController() else {
			assertionFailure("Cannot get trackers view controller")
			return
		}

		let statisticsSetupper = StatisticsViewControllerSetupper(
			trackersRecordService: serviceSetupper.trackersRecordService
		)

		let statisticsViewController = statisticsSetupper.getViewController()

		self.viewControllers = [trackersViewController, statisticsViewController]
        
		self.setupTabBar()
    }
}

private extension TabBarViewController {
	func setupTabBar() {
		let appearance = UITabBarAppearance()
		appearance.backgroundColor = .Dynamic.whiteDay
		self.tabBar.standardAppearance = appearance
	}

	func prepareServiceSetupper() -> ServiceSetupperProtocol? {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
			  let trackersDataStore = appDelegate.trackersDataStore,
			  let trackersCategoryDataStore = appDelegate.trackersCategoryDataStore,
			  let trackersRecordDataStore = appDelegate.trackersRecordDataStore
		else { return nil }

		let trackersFactory = TrackersFactory()
		let trackersCategoryFactory = TrackersCategoryFactory(trackersFactory: trackersFactory)

		let serviceSetupper = ServiceSetupper(
			trackersFactory: trackersFactory,
			trackersCategoryFactory: trackersCategoryFactory,
			trackersDataStore: trackersDataStore,
			trackersCategoryDataStore: trackersCategoryDataStore,
			trackersRecordDataStore: trackersRecordDataStore
		)
		return serviceSetupper
	}
}
