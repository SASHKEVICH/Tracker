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
        
		guard let trackersViewController = setupTrackersViewController() else { return }
        let statisticsViewController = setupStatisticsViewController()
        viewControllers = [trackersViewController, statisticsViewController]
        
        setupTabBar()
    }
    
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
		appearance.backgroundColor = .Dynamic.whiteDay
        tabBar.standardAppearance = appearance
    }
}

// MARK: Setup view controllers
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
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "TrackersTabBarItem"),
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
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "StatisticsTabBarItem"),
            selectedImage: nil)
        return navigationController
    }
}
