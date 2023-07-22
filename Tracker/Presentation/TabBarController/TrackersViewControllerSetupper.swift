//
//  TrackersViewControllerSetupper.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.07.2023.
//

import UIKit

final class TrackersViewControllerSetupper {
    private let trackersViewController = TrackersViewController()
    private let trackersCategoryService: TrackersCategoryServiceProtocol
    private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol
    private let trackersService: TrackersServiceProtocol
    private let trackersAddingService: TrackersAddingServiceProtocol
    private let trackersRecordService: TrackersRecordServiceProtocol
    private let trackersCompletingService: TrackersCompletingServiceProtocol
    private let trackersPinningService: TrackersPinningServiceProtocol
    private let alertPresenterService: AlertPresenterService
    private let analyticsService: AnalyticsServiceProtocol
    private let pinnedCategoryId: UUID

    func getViewController() -> UINavigationController? {
        guard let presenter = preparePresenter() else { return nil }

        trackersViewController.presenter = presenter
        presenter.view = trackersViewController

        let controller = prepareNavigationController()
        return controller
    }

    init(
        trackersCategoryService: TrackersCategoryServiceProtocol,
        trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol,
        trackersService: TrackersServiceProtocol,
        trackersAddingService: TrackersAddingServiceProtocol,
        trackersRecordService: TrackersRecordServiceProtocol,
        trackersCompletingService: TrackersCompletingServiceProtocol,
        trackersPinningService: TrackersPinningServiceProtocol,
        alertPresenterService: AlertPresenterService,
        analyticsService: AnalyticsServiceProtocol,
        pinnedCategoryId: UUID
    ) {
        self.trackersCategoryService = trackersCategoryService
        self.trackersCategoryAddingService = trackersCategoryAddingService
        self.trackersService = trackersService
        self.trackersAddingService = trackersAddingService
        self.trackersRecordService = trackersRecordService
        self.trackersCompletingService = trackersCompletingService
        self.trackersPinningService = trackersPinningService
        self.alertPresenterService = alertPresenterService
        self.analyticsService = analyticsService
        self.pinnedCategoryId = pinnedCategoryId
    }
}

private extension TrackersViewControllerSetupper {
    func preparePresenter() -> TrackersViewPresenter? {
        guard let router = prepareRouter(
            trackersCategoryService: trackersCategoryService,
            trackersCategoryAddingService: trackersCategoryAddingService,
            trackersService: self.trackersService,
            trackersAddingService: trackersAddingService,
            trackersRecordService: self.trackersRecordService,
            trackersCompletingService: trackersCompletingService,
            pinnedCategoryId: pinnedCategoryId
        ) else { return nil }

        var alertPresenterService = self.alertPresenterService
        alertPresenterService.delegate = trackersViewController

        let presenter = TrackersViewPresenter(
            trackersService: self.trackersService,
            trackersAddingService: trackersAddingService,
            trackersCompletingService: trackersCompletingService,
            trackersRecordService: self.trackersRecordService,
            trackersPinningService: trackersPinningService,
            router: router,
            alertPresenterService: alertPresenterService,
            analyticsService: analyticsService
        )

        var trackersService = self.trackersService
        trackersService.trackersDataProviderDelegate = presenter

        var trackersRecordService = self.trackersRecordService
        trackersRecordService.delegate = presenter

        return presenter
    }

    func prepareNavigationController() -> UINavigationController {
        let title = R.string.localizable.tabbarTracker()
        trackersViewController.tabBarItem = UITabBarItem(title: title, image: .TabBar.trackers, selectedImage: nil)
        let navigationController = UINavigationController(rootViewController: trackersViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }
}

private extension TrackersViewControllerSetupper {
    func prepareRouter(
        trackersCategoryService: TrackersCategoryServiceProtocol,
        trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol,
        trackersService: TrackersServiceProtocol,
        trackersAddingService: TrackersAddingServiceProtocol,
        trackersRecordService: TrackersRecordServiceProtocol,
        trackersCompletingService: TrackersCompletingServiceProtocol,
        pinnedCategoryId: UUID
    ) -> TrackersViewRouter? {
        guard let trackersService = trackersService as? TrackersServiceFilteringProtocol else { return nil }
        let router = TrackersViewRouter(
            viewController: trackersViewController,
            trackersCategoryService: trackersCategoryService,
            trackersCategoryAddingService: trackersCategoryAddingService,
            trackersService: trackersService,
            trackersAddingService: trackersAddingService,
            trackersRecordService: trackersRecordService,
            trackersCompletingService: trackersCompletingService,
            pinnedCategoryId: pinnedCategoryId
        )
        return router
    }
}
