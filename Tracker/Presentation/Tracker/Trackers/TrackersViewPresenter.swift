//
//  TrackersViewPresenter.swift
//  Tracker
//
//  Created by Александр Бекренев on 02.04.2023.
//

import Foundation

protocol TrackersViewPresetnerCollectionViewProtocol: AnyObject {
    var completedTrackersRecords: Set<TrackerRecord> { get }
    var currentDate: Date { get }

    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker?
    func completedTimesCount(trackerId: UUID) -> Int
    func categoryTitle(at indexPath: IndexPath) -> String?

    func didRecievedEmptyTrackers()
    func didRecievedNonEmptyTrackers()

    func didTapPinTracker(shouldPin: Bool, _ tracker: Tracker)
    func didTapEditTracker(_ tracker: Tracker)
    func didTapDeleteTracker(_ tracker: Tracker)

    func complete(tracker: Tracker) throws
    func incomplete(tracker: Tracker) throws
}

protocol TrackersViewPresetnerSearchControllerProtocol: AnyObject {
    func requestFilteredTrackers(for searchText: String?)
    func requestShowAllCategoriesForCurrentDay()
}

protocol TrackersViewPresenterProtocol: AnyObject {
    var view: TrackersViewControllerFullProtocol? { get set }
    var collectionHelper: TrackersViewPresenterCollectionViewHelperProtocol { get }
    var searchControllerHelper: TrackersViewPresenterSearchControllerHelperProtocol { get }
    var analyticsService: AnalyticsServiceProtocol { get }
    var currentDate: Date { get }
    func requestTrackers(for date: Date)
    func viewDidLoad()
    func navigateToTrackerTypeScreen()
    func navigateToFilterScreen(chosenDate: Date, selectedFilter: TrackerCategory?)
    func eraseOperations()
}

typealias TrackersViewPresenterFullProtocol =
    TrackersViewPresenterProtocol
        & TrackersViewPresetnerCollectionViewProtocol
        & TrackersViewPresetnerSearchControllerProtocol

// MARK: - TrackersViewPresenter

final class TrackersViewPresenter {
    enum TrackersViewPresenterError: Error {
        case currentDateLaterThanToday
    }

    private enum TrackersViewPresenterState {
        case search
        case normal
    }

    let analyticsService: AnalyticsServiceProtocol

    weak var view: TrackersViewControllerFullProtocol?
    var completedTrackersRecords: Set<TrackerRecord> = []
    var currentDate: Date = .init()

    lazy var collectionHelper: TrackersViewPresenterCollectionViewHelperProtocol = {
        let collectionHelper = TrackersViewPresenterCollectionHelper()
        collectionHelper.presenter = self
        return collectionHelper
    }()

    lazy var searchControllerHelper: TrackersViewPresenterSearchControllerHelperProtocol = {
        let searchControllerHelper = TrackersViewPresenterSearchControllerHelper()
        searchControllerHelper.presenter = self
        return searchControllerHelper
    }()

    private let trackersService: TrackersServiceProtocol
    private let trackersAddingService: TrackersAddingServiceProtocol
    private let trackersCompletingService: TrackersCompletingServiceProtocol
    private let trackersRecordService: TrackersRecordServiceProtocol
    private let trackersPinningService: TrackersPinningServiceProtocol
    private let router: TrackersViewRouterProtocol
    private let alertPresenterService: AlertPresenterSerivceProtocol

    private var state: TrackersViewPresenterState = .normal

    init(
        trackersService: TrackersServiceProtocol,
        trackersAddingService: TrackersAddingServiceProtocol,
        trackersCompletingService: TrackersCompletingServiceProtocol,
        trackersRecordService: TrackersRecordServiceProtocol,
        trackersPinningService: TrackersPinningServiceProtocol,
        router: TrackersViewRouterProtocol,
        alertPresenterService: AlertPresenterSerivceProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.trackersService = trackersService
        self.trackersAddingService = trackersAddingService
        self.trackersCompletingService = trackersCompletingService
        self.trackersRecordService = trackersRecordService
        self.trackersPinningService = trackersPinningService
        self.router = router
        self.alertPresenterService = alertPresenterService
        self.analyticsService = analyticsService
    }
}

// MARK: - TrackersViewPresenterProtocol

extension TrackersViewPresenter: TrackersViewPresenterProtocol {
    func eraseOperations() {
        trackersService.eraseOperations()
    }

    func requestTrackers(for date: Date) {
        guard let weekDay = date.weekDay else { return }
        currentDate = date

        trackersService.fetchTrackers(weekDay: weekDay)
        fetchCompletedTrackersForCurrentDate()
    }

    func viewDidLoad() {
        fetchCompletedTrackersForCurrentDate()
    }

    func navigateToTrackerTypeScreen() {
        router.navigateToTrackerTypeScreen()
    }

    func navigateToFilterScreen(chosenDate: Date, selectedFilter: TrackerCategory?) {
        router.navigateToFilterScreen(chosenDate: chosenDate, selectedFilter: selectedFilter)
    }
}

// MARK: - TrackersViewPresetnerSearchControllerProtocol

extension TrackersViewPresenter: TrackersViewPresetnerSearchControllerProtocol {
    func requestFilteredTrackers(for searchText: String?) {
        guard let titleSearchString = searchText, let weekDay = currentDate.weekDay else { return }
        state = .search

        trackersService.fetchTrackers(titleSearchString: titleSearchString, currentWeekDay: weekDay)
        fetchCompletedTrackersForCurrentDate()
    }

    func requestShowAllCategoriesForCurrentDay() {
        state = .normal
        requestTrackers(for: currentDate)
    }
}

// MARK: - TrackersViewPresetnerCollectionViewProtocol

extension TrackersViewPresenter: TrackersViewPresetnerCollectionViewProtocol {
    var numberOfSections: Int {
        trackersService.numberOfSections
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        trackersService.numberOfItemsInSection(section)
    }

    func tracker(at indexPath: IndexPath) -> Tracker? {
        trackersService.tracker(at: indexPath)
    }

    func categoryTitle(at indexPath: IndexPath) -> String? {
        trackersService.categoryTitle(at: indexPath)
    }

    func completedTimesCount(trackerId: UUID) -> Int {
        trackersRecordService.completedTimesCount(trackerId: trackerId)
    }

    func didRecievedEmptyTrackers() {
        switch state {
        case .normal:
            view?.showPlaceholderViewForCurrentDay()
        case .search:
            view?.showPlaceholderViewForEmptySearch()
        }
    }

    func didRecievedNonEmptyTrackers() {
        view?.shouldHidePlaceholderView(true)
    }

    func didTapPinTracker(shouldPin: Bool, _ tracker: Tracker) {
        if shouldPin {
            trackersPinningService.pin(tracker: tracker)
        } else {
            trackersPinningService.unpin(tracker: tracker)
        }
    }

    func didTapEditTracker(_ tracker: Tracker) {
        analyticsService.didEditTracker()
        router.navigateToEditTrackerScreen(tracker: tracker)
    }

    func didTapDeleteTracker(_ tracker: Tracker) {
        alertPresenterService.requestDeleteTrackerAlert { [weak self] _ in
            guard let self = self else { return }
            self.analyticsService.didDeleteTracker()
            self.trackersAddingService.delete(tracker: tracker)
        }
    }

    func requestChosenFutureDateAlert() {
        alertPresenterService.requestChosenFutureDateAlert()
    }

    func complete(tracker: Tracker) throws {
        try checkCurrentDate()
        analyticsService.didTapTracker()
        trackersCompletingService.completeTracker(trackerId: tracker.id, date: currentDate)
    }

    func incomplete(tracker: Tracker) throws {
        try checkCurrentDate()
        analyticsService.didTapTracker()
        trackersCompletingService.incompleteTracker(trackerId: tracker.id, date: currentDate)
    }
}

// MARK: - TrackersDataProviderDelegate

extension TrackersViewPresenter: TrackersDataProviderDelegate {
    func insertSections(at: IndexSet) {
        view?.insertSections(at: at)
        fetchCompletedTrackersForCurrentDate()
    }

    func deleteSections(at: IndexSet) {
        view?.deleteSections(at: at)
        fetchCompletedTrackersForCurrentDate()
    }

    func reloadSections(at: IndexSet) {
        view?.reloadSections(at: at)
    }

    func insertItems(at: TrackersCollectionCellIndices) {
        view?.insertItems(at: at)
        fetchCompletedTrackersForCurrentDate()
    }

    func deleteItems(at: TrackersCollectionCellIndices) {
        view?.deleteItems(at: at)
        fetchCompletedTrackersForCurrentDate()
    }

    func moveItems(at: IndexPath, to: IndexPath) {
        view?.moveItems(at: at, to: to)
        fetchCompletedTrackersForCurrentDate()
    }

    func reloadItems(at: TrackersCollectionCellIndices) {
        view?.reloadItems(at: at)
        fetchCompletedTrackersForCurrentDate()
    }

    func didChangeContent(operations: [BlockOperation]) {
        view?.didChangeContentAnimated(operations: operations)
    }

    func fetchDidPerformed() {
        updateTrackers()
    }
}

// MARK: - TrackersRecordServiceDelegate

extension TrackersViewPresenter: TrackersRecordServiceDelegate {
    func didRecieveCompletedTrackers(_ records: [TrackerRecord]) {
        completedTrackersRecords = Set(records)
    }
}

private extension TrackersViewPresenter {
    var isCurrentDateLaterThanToday: Bool {
        currentDate > Date()
    }

    func checkCurrentDate() throws {
        if isCurrentDateLaterThanToday {
            requestChosenFutureDateAlert()
            throw TrackersViewPresenterError.currentDateLaterThanToday
        }
    }

    func fetchCompletedTrackersForCurrentDate() {
        trackersRecordService.fetchCompletedRecords(for: currentDate)
    }

    func updateTrackers() {
        DispatchQueue.main.async { [weak self] in
            self?.view?.didRecieveTrackers()
        }
    }
}
