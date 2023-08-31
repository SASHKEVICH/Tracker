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
    func getViewController() -> StatisticsViewController {
        let viewModel = StatisticsViewModel(trackersCompletingService: self.trackersCompletingService)

        self.trackersCompletingService.delegate = viewModel

        let tableViewHelper = StatisticsTableViewHelper()
        let statisticsViewController = StatisticsViewController(
            viewModel: viewModel,
            tableViewHelper: tableViewHelper
        )

        tableViewHelper.delegate = statisticsViewController

        return statisticsViewController
    }
}
