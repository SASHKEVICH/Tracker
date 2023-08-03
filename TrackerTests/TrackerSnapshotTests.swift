//
//  TrackerSnapshotTests.swift
//  TrackerTests
//
//  Created by Александр Бекренев on 17.07.2023.
//

import SnapshotTesting
@testable import Tracker
import XCTest

final class TrackerSnapshotTests: XCTestCase {
    func testStatisticsScreen() throws {
        let service = TrackersCompletingServiceStub()
        let viewModel = StatisticsViewModel(trackersCompletingService: service)

        service.delegate = viewModel

        let tableViewHelper = StatisticsTableViewHelper()
        let vc = StatisticsViewController(viewModel: viewModel, tableViewHelper: tableViewHelper)

        tableViewHelper.delegate = vc

        assertSnapshots(matching: vc, as: [
            .image(traits: UITraitCollection(userInterfaceStyle: .light)),
        ])
        assertSnapshots(matching: vc, as: [
            .image(traits: UITraitCollection(userInterfaceStyle: .dark)),
        ])
    }

    func testTrackersScreenEmpty() throws {
        let vc = TrackersViewController()

        let categoryService = TrackersCategoryServiceStub(state: .empty)
        let categoryAddingService = TrackersCategoryAddingServiceStub()
        let trackersService = TrackersServiceStub(state: .empty)
        let tracersAddingService = TrackersAddingServiceStub()
        let trackersRecordService = TrackersRecordServiceStub()
        let trackerCompletingService = TrackersCompletingServiceStub()
        let trakersPinningService = TrackersPinningServiceStub()

        let router = TrackersViewRouter(
            viewController: vc,
            trackersCategoryService: categoryService,
            trackersCategoryAddingService: categoryAddingService,
            trackersService: trackersService,
            trackersAddingService: tracersAddingService,
            trackersRecordService: trackersRecordService,
            trackersCompletingService: trackerCompletingService,
            pinnedCategoryId: UUID()
        )

        let presenter = TrackersViewPresenter(
            trackersService: trackersService,
            trackersAddingService: tracersAddingService,
            trackersCompletingService: trackerCompletingService,
            trackersRecordService: trackersRecordService,
            trackersPinningService: trakersPinningService,
            router: router,
            alertPresenterService: AlertPresenterService(),
            analyticsService: AnalyticsService()
        )

        vc.presenter = presenter
        presenter.view = vc

        assertSnapshots(matching: vc, as: [
            .image(traits: UITraitCollection(userInterfaceStyle: .light)),
        ])
        assertSnapshots(matching: vc, as: [
            .image(traits: UITraitCollection(userInterfaceStyle: .dark)),
        ])
    }

    func testTrackersScreenNotEmpty() throws {
        let vc = TrackersViewController()

        let categoryService = TrackersCategoryServiceStub(state: .notEmpty)
        let categoryAddingService = TrackersCategoryAddingServiceStub()
        let trackersService = TrackersServiceStub(state: .notEmpty)
        let tracersAddingService = TrackersAddingServiceStub()
        let trackersRecordService = TrackersRecordServiceStub()
        let trackerCompletingService = TrackersCompletingServiceStub()
        let trakersPinningService = TrackersPinningServiceStub()

        let router = TrackersViewRouter(
            viewController: vc,
            trackersCategoryService: categoryService,
            trackersCategoryAddingService: categoryAddingService,
            trackersService: trackersService,
            trackersAddingService: tracersAddingService,
            trackersRecordService: trackersRecordService,
            trackersCompletingService: trackerCompletingService,
            pinnedCategoryId: UUID()
        )

        let presenter = TrackersViewPresenter(
            trackersService: trackersService,
            trackersAddingService: tracersAddingService,
            trackersCompletingService: trackerCompletingService,
            trackersRecordService: trackersRecordService,
            trackersPinningService: trakersPinningService,
            router: router,
            alertPresenterService: AlertPresenterService(),
            analyticsService: AnalyticsService()
        )

        vc.presenter = presenter
        presenter.view = vc

        assertSnapshots(matching: vc, as: [
            .image(drawHierarchyInKeyWindow: true, traits: UITraitCollection(userInterfaceStyle: .light)),
        ])
        assertSnapshots(matching: vc, as: [
            .image(drawHierarchyInKeyWindow: true, traits: UITraitCollection(userInterfaceStyle: .dark)),
        ])
    }
}
