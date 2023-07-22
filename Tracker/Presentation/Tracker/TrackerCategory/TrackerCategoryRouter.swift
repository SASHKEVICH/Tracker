//
//  TrackerCategoryRouter.swift
//  Tracker
//
//  Created by Александр Бекренев on 09.07.2023.
//

import UIKit

protocol TrackerCategoryRouterProtocol {
    func navigateToNewCategoryScreen(from viewController: TrackerCategoryViewController)
}

final class TrackerCategoryRouter {
    private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol

    init(trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol) {
        self.trackersCategoryAddingService = trackersCategoryAddingService
    }
}

// MARK: - TrackerCategoryRouterProtocol

extension TrackerCategoryRouter: TrackerCategoryRouterProtocol {
    func navigateToNewCategoryScreen(from viewController: TrackerCategoryViewController) {
        let viewModel = TrackerNewCategoryViewModel(trackersCategoryAddingService: trackersCategoryAddingService)
        let vc = TrackerNewCategoryViewController(viewModel: viewModel)

        vc.emptyTap = { [weak vc] in
            vc?.view.endEditing(true)
        }
        vc.delegate = viewController

        viewController.present(vc, animated: true)
    }
}
