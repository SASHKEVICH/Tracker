//
//  StatisticsViewControllerSetupper.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.07.2023.
//

import UIKit

struct StatisticsViewControllerSetupper {
	func getViewController() -> UINavigationController {
		let viewModel = StatisticsViewModel()
		let statisticsViewController = StatisticsViewController(viewModel: viewModel)
		let navigationController = UINavigationController(rootViewController: statisticsViewController)
		navigationController.navigationBar.prefersLargeTitles = true

		let title = R.string.localizable.tabbarStatistics()
		statisticsViewController.tabBarItem = UITabBarItem(
			title: title,
			image: .TabBar.statistics,
			selectedImage: nil)
		return navigationController
	}
}
