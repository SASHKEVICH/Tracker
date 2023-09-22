//
//  ServiceSetupper.swift
//  Tracker
//
//  Created by Александр Бекренев on 17.07.2023.
//

import Foundation

protocol ServiceSetupperProtocol {
    var trackersService: TrackersService { get }
    var trackersAddingService: TrackersAddingService { get }
    var trackersCompletingService: TrackersCompletingService { get }
    var trackersRecordService: TrackersRecordService { get }
    var trackersCategoryService: TrackersCategoryService { get }
    var trackersCategoryAddingService: TrackersCategoryAddingService { get }
    var trackersPinningService: TrackersPinningService { get }
    var alertPresenterService: AlertPresenterService { get }
    var analyticsService: AnalyticsService { get }
    var pinnedCategoryId: UUID? { get }
}

final class ServiceSetupper {
    let trackersService: TrackersService
    let trackersAddingService: TrackersAddingService
    let trackersCompletingService: TrackersCompletingService
    let trackersRecordService: TrackersRecordService
    let trackersCategoryService: TrackersCategoryService
    let trackersCategoryAddingService: TrackersCategoryAddingService
    let trackersPinningService: TrackersPinningService
    let alertPresenterService: AlertPresenterService
    let analyticsService: AnalyticsService

    var pinnedCategoryId: UUID?

    init?(
        trackersFactory: TrackersFactory,
        trackersCategoryFactory: TrackersCategoryFactory,
        trackersDataStore: TrackersDataStore,
        trackersCategoryDataStore: TrackersCategoryDataStore,
        trackersRecordDataStore: TrackersRecordDataStore
    ) {
        self.trackersService = ServiceSetupper.prepareTrackersService(
            trackersFactory: trackersFactory,
            trackersDataStore: trackersDataStore
        )

        self.trackersCompletingService = ServiceSetupper.prepareTrackersCompletingService(
            trackersRecordDataStore: trackersRecordDataStore,
            trackersDataStore: trackersDataStore
        )

        self.trackersRecordService = ServiceSetupper.prepareTrackersRecordService(
            trackersRecordDataStore: trackersRecordDataStore
        )

        self.trackersCategoryService = ServiceSetupper.prepareTrackersCategoryService(
            trackersCategoryFactory: trackersCategoryFactory,
            trackersCategoryDataStore: trackersCategoryDataStore
        )

        self.trackersCategoryAddingService = ServiceSetupper.prepareTrackersCategoryAddingService(
            trackersCategoryFactory: trackersCategoryFactory,
            trackersCategoryDataStore: trackersCategoryDataStore
        )

        self.pinnedCategoryId = ServiceSetupper.preparePinnedCategoryId(
            trackersCategoryFactory: trackersCategoryFactory,
            trackersCategoryDataStore: trackersCategoryDataStore
        )

        guard let pinnedCategoryId = self.pinnedCategoryId else {
            assertionFailure("Cannot load pinned category id")
            return nil
        }

        self.trackersPinningService = ServiceSetupper.prepareTrackersPinningService(
            pinnedCategoryId: pinnedCategoryId,
            trackersFactory: trackersFactory,
            trackersDataStore: trackersDataStore,
            trackersCategoryDataStore: trackersCategoryDataStore
        )

        self.trackersAddingService = ServiceSetupper.prepareTrackersAddingService(
            trackersFactory: trackersFactory,
            trackersDataStore: trackersDataStore,
            trackersCategoryDataStore: trackersCategoryDataStore,
            pinnedCategoryId: pinnedCategoryId
        )

        self.analyticsService = AnalyticsService()
        self.alertPresenterService = AlertPresenterService()
    }
}

// MARK: - ServiceSetupperProtocol

extension ServiceSetupper: ServiceSetupperProtocol {}

private extension ServiceSetupper {
    static func prepareTrackersService(
        trackersFactory: TrackersFactory,
        trackersDataStore: TrackersDataStore
    ) -> TrackersService {
        let operationFactory = BlockOperationFactory()
        let provider = TrackersDataProvider(
            context: trackersDataStore.managedObjectContext,
            blockOperationFactory: operationFactory
        )
        let service = TrackersService(trackersFactory: trackersFactory, trackersDataProvider: provider)
        return service
    }

    static func prepareTrackersAddingService(
        trackersFactory: TrackersFactory,
        trackersDataStore: TrackersDataStore,
        trackersCategoryDataStore: TrackersCategoryDataStore,
        pinnedCategoryId: UUID
    ) -> TrackersAddingService {
        let adder = TrackersDataAdder(
            trackersCategoryDataStore: trackersCategoryDataStore,
            trackersDataStore: trackersDataStore,
            pinnedCategoryId: pinnedCategoryId,
            trackersFactory: trackersFactory
        )

        let trackersAddingService = TrackersAddingService(trackersFactory: trackersFactory, trackersDataAdder: adder)
        return trackersAddingService
    }

    static func prepareTrackersCompletingService(
        trackersRecordDataStore: TrackersRecordDataStore,
        trackersDataStore: TrackersDataStore
    ) -> TrackersCompletingService {
        let completer = TrackersDataCompleter(
            trackersRecordDataStore: trackersRecordDataStore,
            trackersDataStore: trackersDataStore
        )
        let service = TrackersCompletingService(trackersDataCompleter: completer)
        return service
    }

    static func prepareTrackersRecordService(
        trackersRecordDataStore: TrackersRecordDataStore
    ) -> TrackersRecordService {
        let fetcher = TrackersRecordDataFetcher(trackersRecordDataStore: trackersRecordDataStore)
        let service = TrackersRecordService(trackersRecordDataFetcher: fetcher)
        return service
    }

    static func prepareTrackersPinningService(
        pinnedCategoryId: UUID,
        trackersFactory: TrackersFactory,
        trackersDataStore: TrackersDataStore,
        trackersCategoryDataStore: TrackersCategoryDataStore
    ) -> TrackersPinningService {
        let pinner = TrackersDataPinner(
            pinnedCategoryId: pinnedCategoryId,
            trackersDataStore: trackersDataStore,
            trackersCategoryDataStore: trackersCategoryDataStore
        )

        let service = TrackersPinningService(trackersFactory: trackersFactory, trackersDataPinner: pinner)
        return service
    }

    static func prepareTrackersCategoryService(
        trackersCategoryFactory: TrackersCategoryFactory,
        trackersCategoryDataStore: TrackersCategoryDataStore
    ) -> TrackersCategoryService {
        let provider = TrackersCategoryDataProvider(context: trackersCategoryDataStore.managedObjectContext)
        let fetcher = TrackersCategoryDataFetcher(trackersCategoryDataStore: trackersCategoryDataStore)

        let service = TrackersCategoryService(
            trackersCategoryFactory: trackersCategoryFactory,
            trackersCategoryDataProvider: provider,
            trackersCategoryDataFetcher: fetcher
        )

        return service
    }

    static func prepareTrackersCategoryAddingService(
        trackersCategoryFactory: TrackersCategoryFactory,
        trackersCategoryDataStore: TrackersCategoryDataStore
    ) -> TrackersCategoryAddingService {
        let adder = TrackersCategoryDataAdder(
            trackersCategoryDataStore: trackersCategoryDataStore,
            trackersCategoryFactory: trackersCategoryFactory
        )

        let service = TrackersCategoryAddingService(
            trackersCategoryFactory: trackersCategoryFactory,
            trackersCategoryDataAdder: adder
        )

        return service
    }

    static func preparePinnedCategoryId(
        trackersCategoryFactory: TrackersCategoryFactory,
        trackersCategoryDataStore: TrackersCategoryDataStore
    ) -> UUID? {
        let pinnedCategoryService = TrackersPinnedCategoryService(
            trackersCategoryFactory: trackersCategoryFactory,
            trackersCategoryDataStore: trackersCategoryDataStore
        )
        pinnedCategoryService?.checkPinnedCategory()
        return pinnedCategoryService?.pinnedCategoryId
    }
}
