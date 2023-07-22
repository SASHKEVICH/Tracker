//
//  StatisticsViewControllerSetupper.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.07.2023.
//

import UIKit

final class StatisticsViewControllerSetupper {
    private var trackersCompletingService: TrackersCompletingServiceStatisticsProtocol

    init(trackersCompletingService: TrackersCompletingServiceStatisticsProtocol) {
        self.trackersCompletingService = trackersCompletingService
    }
}

extension StatisticsViewControllerSetupper {
    func getViewController() -> UINavigationController {
        let viewModel = StatisticsViewModel(trackersCompletingService: self.trackersCompletingService)

        self.trackersCompletingService.delegate = viewModel

        let tableViewHelper = StatisticsTableViewHelper()
        let statisticsViewController = StatisticsViewController(
            viewModel: viewModel,
            tableViewHelper: tableViewHelper
        )

        tableViewHelper.delegate = statisticsViewController

        let navigationController = UINavigationController(rootViewController: statisticsViewController)
        navigationController.navigationBar.prefersLargeTitles = true

        let title = R.string.localizable.tabbarStatistics()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: title,
            image: .TabBar.statistics,
            selectedImage: nil
        )
        return navigationController
    }
}
