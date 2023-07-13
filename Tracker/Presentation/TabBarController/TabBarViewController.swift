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
        
		guard let trackersViewController = self.setupTrackersViewController() else { return }

		let statisticsViewController = self.setupStatisticsViewController()
		self.viewControllers = [trackersViewController, statisticsViewController]
        
		self.setupTabBar()
    }
}

// MARK: - Setup view controllers
private extension TabBarViewController {
    func setupTrackersViewController() -> UINavigationController? {
        let trackersViewController = TrackersViewController()

		let trackersFactory = TrackersFactory()
		guard let trackersService = TrackersService(trackersFactory: trackersFactory),
			  let completingService = TrackersCompletingService(),
			  let recordService = TrackersRecordService()
		else {
			assertionFailure("Cannot init services")
			return nil
		}

		let router = TrackersViewRouter(viewController: trackersViewController)
        let presenter = TrackersViewPresenter(
            trackersService: trackersService,
			trackersCompletingService: completingService,
			trackersRecordService: recordService,
			router: router
		)
        
        trackersViewController.presenter = presenter
        presenter.view = trackersViewController

		let title = R.string.localizable.tabbarTracker()
        trackersViewController.tabBarItem = UITabBarItem(
            title: title,
            image: .TabBar.trackers,
            selectedImage: nil)
        
        let navigationController = UINavigationController(
            rootViewController: trackersViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        
        return navigationController
    }
    
    func setupStatisticsViewController() -> UINavigationController {
        let statisticsViewController = StatisticsViewController()
        let navigationController = UINavigationController(
            rootViewController: statisticsViewController)
        navigationController.navigationBar.prefersLargeTitles = true

		let title = R.string.localizable.tabbarStatistics()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: title,
			image: .TabBar.statistics,
            selectedImage: nil)
        return navigationController
    }
}

private extension TabBarViewController {
	func setupTabBar() {
		let appearance = UITabBarAppearance()
		appearance.backgroundColor = .Dynamic.whiteDay
		self.tabBar.standardAppearance = appearance
	}
}
