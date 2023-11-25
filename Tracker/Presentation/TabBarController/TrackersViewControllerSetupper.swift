//
//  TrackersViewControllerSetupper.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.07.2023.
//

import UIKit

final class TrackersViewControllerSetupper {
    private let trackersViewController = MainViewController()
    private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol
    private let trackersService: TrackersServiceProtocol
    private let trackersAddingService: TrackersAddingServiceProtocol
    private let trackersRecordService: TrackersRecordServiceProtocol
    private let trackersCompletingService: TrackersCompletingServiceProtocol
    private let trackersPinningService: TrackersPinningServiceProtocol
    private let getCategoriesUseCase: GetCategoriesUseCaseProtocol
    private let alertPresenterService: AlertPresenterService
    private let pinnedCategoryId: UUID

    func getViewController() -> UINavigationController? {
        guard let presenter = self.preparePresenter() else { return nil }

        self.trackersViewController.presenter = presenter
        presenter.view = self.trackersViewController

        let controller = self.prepareNavigationController()
        return controller
    }

    init(
        trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol,
        trackersService: TrackersServiceProtocol,
        trackersAddingService: TrackersAddingServiceProtocol,
        trackersRecordService: TrackersRecordServiceProtocol,
        trackersCompletingService: TrackersCompletingServiceProtocol,
        trackersPinningService: TrackersPinningServiceProtocol,
        getCategoriesUseCase: GetCategoriesUseCaseProtocol,
        alertPresenterService: AlertPresenterService,
        pinnedCategoryId: UUID
    ) {
        self.trackersCategoryAddingService = trackersCategoryAddingService
        self.trackersService = trackersService
        self.trackersAddingService = trackersAddingService
        self.trackersRecordService = trackersRecordService
        self.trackersCompletingService = trackersCompletingService
        self.trackersPinningService = trackersPinningService
        self.getCategoriesUseCase = getCategoriesUseCase
        self.alertPresenterService = alertPresenterService
        self.pinnedCategoryId = pinnedCategoryId
    }
}

private extension TrackersViewControllerSetupper {
    func preparePresenter() -> MainViewPresenter? {
        guard let router = self.prepareRouter(
            trackersCategoryAddingService: self.trackersCategoryAddingService,
            trackersService: self.trackersService,
            trackersAddingService: self.trackersAddingService,
            trackersRecordService: self.trackersRecordService,
            trackersCompletingService: self.trackersCompletingService,
            getCategoriesUseCase: self.getCategoriesUseCase,
            pinnedCategoryId: self.pinnedCategoryId
        ) else { return nil }

        let alertPresenterService = self.alertPresenterService
        alertPresenterService.delegate = self.trackersViewController

        let presenter = MainViewPresenter(
            trackersService: self.trackersService,
            trackersAddingService: self.trackersAddingService,
            trackersCompletingService: self.trackersCompletingService,
            trackersRecordService: self.trackersRecordService,
            trackersPinningService: self.trackersPinningService,
            router: router,
            alertPresenterService: alertPresenterService
        )

        var trackersService = self.trackersService
        trackersService.trackersDataProviderDelegate = presenter

        var trackersRecordService = self.trackersRecordService
        trackersRecordService.delegate = presenter

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
    func prepareRouter(
        trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol,
        trackersService: TrackersServiceProtocol,
        trackersAddingService: TrackersAddingServiceProtocol,
        trackersRecordService: TrackersRecordServiceProtocol,
        trackersCompletingService: TrackersCompletingServiceProtocol,
        getCategoriesUseCase: GetCategoriesUseCaseProtocol,
        pinnedCategoryId: UUID
    ) -> MainViewRouter? {
        guard let trackersService = trackersService as? TrackersServiceFilteringProtocol else { return nil }
        let router = MainViewRouter(
            viewController: self.trackersViewController,
            trackersCategoryAddingService: trackersCategoryAddingService,
            trackersService: trackersService,
            trackersAddingService: trackersAddingService,
            trackersRecordService: trackersRecordService,
            trackersCompletingService: trackersCompletingService,
            getCategoriesUseCase: getCategoriesUseCase,
            pinnedCategoryId: pinnedCategoryId
        )
        return router
    }
}
