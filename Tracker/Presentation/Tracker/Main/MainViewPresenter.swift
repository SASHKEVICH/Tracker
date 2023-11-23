import Foundation

protocol MainViewPresetnerCollectionViewProtocol: AnyObject {
    var completedTrackersRecords: Set<Record> { get }
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

protocol MainViewPresetnerSearchControllerProtocol: AnyObject {
    func requestFilteredTrackers(for searchText: String?)
    func requestShowAllCategoriesForCurrentDay()
}

protocol MainViewPresenterProtocol: AnyObject {
    var view: MainViewControllerFullProtocol? { get set }
    var collectionHelper: MainViewCollectionHelperProtocol { get }
    var searchControllerHelper: MainViewSearchControllerHelperProtocol { get }
    var currentDate: Date { get }
    func requestTrackers(for date: Date)
    func viewDidLoad()
    func navigateToTrackerTypeScreen()
    func navigateToFilterScreen(chosenDate: Date, selectedFilter: Category?)
    func eraseOperations()
}

typealias MainViewPresenterFullProtocol = MainViewPresenterProtocol
                                          & MainViewPresetnerCollectionViewProtocol
                                          & MainViewPresetnerSearchControllerProtocol

final class MainViewPresenter {
    enum MainViewPresenterError: Error {
        case currentDateLaterThanToday
    }

    private enum MainViewPresenterState {
        case search
        case normal
    }

    weak var view: MainViewControllerFullProtocol?
    var completedTrackersRecords: Set<Record> = []
    var currentDate: Date = .init()

    lazy var collectionHelper: MainViewCollectionHelperProtocol = {
        let collectionHelper = MainViewCollectionHelper()
        collectionHelper.presenter = self
        return collectionHelper
    }()

    lazy var searchControllerHelper: MainViewSearchControllerHelperProtocol = {
        let searchControllerHelper = MainViewSearchControllerHelper()
        searchControllerHelper.presenter = self
        return searchControllerHelper
    }()

    private let trackersService: TrackersServiceProtocol
    private let trackersAddingService: TrackersAddingServiceProtocol
    private let trackersCompletingService: TrackersCompletingServiceProtocol
    private let trackersRecordService: TrackersRecordServiceProtocol
    private let trackersPinningService: TrackersPinningServiceProtocol
    private let router: MainViewRouterProtocol
    private let alertPresenterService: AlertPresenterSerivceProtocol

    private var state: MainViewPresenterState = .normal

    init(
        trackersService: TrackersServiceProtocol,
        trackersAddingService: TrackersAddingServiceProtocol,
        trackersCompletingService: TrackersCompletingServiceProtocol,
        trackersRecordService: TrackersRecordServiceProtocol,
        trackersPinningService: TrackersPinningServiceProtocol,
        router: MainViewRouterProtocol,
        alertPresenterService: AlertPresenterSerivceProtocol
    ) {
        self.trackersService = trackersService
        self.trackersAddingService = trackersAddingService
        self.trackersCompletingService = trackersCompletingService
        self.trackersRecordService = trackersRecordService
        self.trackersPinningService = trackersPinningService
        self.router = router
        self.alertPresenterService = alertPresenterService
    }
}

// MARK: - MainViewPresenterProtocol

extension MainViewPresenter: MainViewPresenterProtocol {
    func eraseOperations() {
        self.trackersService.eraseOperations()
    }

    func requestTrackers(for date: Date) {
        guard let weekDay = date.weekDay else { return }
        self.currentDate = date

        self.trackersService.fetchTrackers(weekDay: weekDay)
        self.fetchCompletedTrackersForCurrentDate()
    }

    func viewDidLoad() {
        self.fetchCompletedTrackersForCurrentDate()
    }

    func navigateToTrackerTypeScreen() {
        self.router.navigateToTrackerTypeScreen()
    }

    func navigateToFilterScreen(chosenDate: Date, selectedFilter: Category?) {
        self.router.navigateToFilterScreen(chosenDate: chosenDate, selectedFilter: selectedFilter)
    }
}

// MARK: - MainViewPresetnerSearchControllerProtocol

extension MainViewPresenter: MainViewPresetnerSearchControllerProtocol {
    func requestFilteredTrackers(for searchText: String?) {
        guard let titleSearchString = searchText, let weekDay = currentDate.weekDay else { return }
        self.state = .search

        self.trackersService.fetchTrackers(titleSearchString: titleSearchString, currentWeekDay: weekDay)
        self.fetchCompletedTrackersForCurrentDate()
    }

    func requestShowAllCategoriesForCurrentDay() {
        self.state = .normal
        self.requestTrackers(for: self.currentDate)
    }
}

// MARK: - MainViewPresetnerCollectionViewProtocol

extension MainViewPresenter: MainViewPresetnerCollectionViewProtocol {
    var numberOfSections: Int {
        self.trackersService.numberOfSections
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        self.trackersService.numberOfItemsInSection(section)
    }

    func tracker(at indexPath: IndexPath) -> Tracker? {
        self.trackersService.tracker(at: indexPath)
    }

    func categoryTitle(at indexPath: IndexPath) -> String? {
        self.trackersService.categoryTitle(at: indexPath)
    }

    func completedTimesCount(trackerId: UUID) -> Int {
        self.trackersRecordService.completedTimesCount(trackerId: trackerId)
    }

    func didRecievedEmptyTrackers() {
        switch self.state {
        case .normal:
            self.view?.showPlaceholderViewForCurrentDay()
        case .search:
            self.view?.showPlaceholderViewForEmptySearch()
        }
    }

    func didRecievedNonEmptyTrackers() {
        self.view?.shouldHidePlaceholderView(true)
    }

    func didTapPinTracker(shouldPin: Bool, _ tracker: Tracker) {
        if shouldPin {
            self.trackersPinningService.pin(tracker: tracker)
        } else {
            self.trackersPinningService.unpin(tracker: tracker)
        }
    }

    func didTapEditTracker(_ tracker: Tracker) {
        self.router.navigateToEditTrackerScreen(tracker: tracker)
    }

    func didTapDeleteTracker(_ tracker: Tracker) {
        self.alertPresenterService.requestDeleteTrackerAlert { [weak self] _ in
            guard let self = self else { return }
            self.trackersAddingService.delete(tracker: tracker)
        }
    }

    func requestChosenFutureDateAlert() {
        self.alertPresenterService.requestChosenFutureDateAlert()
    }

    func complete(tracker: Tracker) throws {
        try self.checkCurrentDate()
        self.trackersCompletingService.completeTracker(trackerId: tracker.id, date: currentDate)
    }

    func incomplete(tracker: Tracker) throws {
        try self.checkCurrentDate()
        self.trackersCompletingService.incompleteTracker(trackerId: tracker.id, date: currentDate)
    }
}

// MARK: - TrackersDataProviderDelegate

extension MainViewPresenter: TrackersDataProviderDelegate {
    func insertSections(at: IndexSet) {
        self.view?.insertSections(at: at)
        self.fetchCompletedTrackersForCurrentDate()
    }

    func deleteSections(at: IndexSet) {
        self.view?.deleteSections(at: at)
        self.fetchCompletedTrackersForCurrentDate()
    }

    func reloadSections(at: IndexSet) {
        self.view?.reloadSections(at: at)
    }

    func insertItems(at: TrackersCollectionCellIndices) {
        self.view?.insertItems(at: at)
        self.fetchCompletedTrackersForCurrentDate()
    }

    func deleteItems(at: TrackersCollectionCellIndices) {
        self.view?.deleteItems(at: at)
        self.fetchCompletedTrackersForCurrentDate()
    }

    func moveItems(at: IndexPath, to: IndexPath) {
        self.view?.moveItems(at: at, to: to)
        self.fetchCompletedTrackersForCurrentDate()
    }

    func reloadItems(at: TrackersCollectionCellIndices) {
        self.view?.reloadItems(at: at)
        self.fetchCompletedTrackersForCurrentDate()
    }

    func didChangeContent(operations: [BlockOperation]) {
        self.view?.didChangeContentAnimated(operations: operations)
    }

    func fetchDidPerformed() {
        self.updateTrackers()
    }
}

// MARK: - TrackersRecordServiceDelegate

extension MainViewPresenter: TrackersRecordServiceDelegate {
    func didRecieveCompletedTrackers(_ records: [Record]) {
        self.completedTrackersRecords = Set(records)
    }
}

private extension MainViewPresenter {
    var isCurrentDateLaterThanToday: Bool {
        self.currentDate > Date()
    }

    func checkCurrentDate() throws {
        if self.isCurrentDateLaterThanToday {
            self.requestChosenFutureDateAlert()
            throw MainViewPresenterError.currentDateLaterThanToday
        }
    }

    func fetchCompletedTrackersForCurrentDate() {
        self.trackersRecordService.fetchCompletedRecords(for: self.currentDate)
    }

    func updateTrackers() {
        DispatchQueue.main.async { [weak self] in
            self?.view?.didRecieveTrackers()
        }
    }
}
