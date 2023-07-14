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

		let trackersSetupper = TrackersViewControllerSetupper()
		guard let trackersViewController = trackersSetupper.getViewController() else { return }

		let statisticsSetupper = StatisticsViewControllerSetupper()
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
}
