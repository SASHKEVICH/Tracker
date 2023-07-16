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
	var currentDate: Date = Date()

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
	private var trackers: [Tracker] = []

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
		self.trackersService.eraseOperations()
	}

	func requestTrackers(for date: Date) {
		guard let weekDay = date.weekDay else { return }
		self.currentDate = date

		self.trackersService.fetchTrackers(weekDay: weekDay)
		self.fetchCompletedTrackersForCurrentDate()
	}

	func viewDidLoad() {
		self.trackers = self.trackersService.trackers
		self.fetchCompletedTrackersForCurrentDate()
	}

	func navigateToTrackerTypeScreen() {
		self.router.navigateToTrackerTypeScreen()
	}

	func navigateToFilterScreen(chosenDate: Date, selectedFilter: TrackerCategory?) {
		self.router.navigateToFilterScreen(chosenDate: chosenDate, selectedFilter: selectedFilter)
	}
}

// MARK: - TrackersViewPresetnerSearchControllerProtocol
extension TrackersViewPresenter: TrackersViewPresetnerSearchControllerProtocol {
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

// MARK: - TrackersViewPresetnerCollectionViewProtocol
extension TrackersViewPresenter: TrackersViewPresetnerCollectionViewProtocol {
    var numberOfSections: Int {
		self.trackersService.numberOfSections
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
		self.trackersService.numberOfItemsInSection(section)
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
		guard self.trackers.isEmpty == false else { return nil }
		let index = indexPath.row + indexPath.section
		return self.trackers[index]
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
		self.analyticsService.didEditTracker()
		self.router.navigateToEditTrackerScreen(tracker: tracker)
	}

	func didTapDeleteTracker(_ tracker: Tracker) {
		self.alertPresenterService.requestDeleteTrackerAlert { [weak self] _ in
			guard let self = self else { return }
			self.analyticsService.didDeleteTracker()
			self.trackersAddingService.delete(tracker: tracker)
		}
	}
    
    func requestChosenFutureDateAlert() {
		self.alertPresenterService.requestChosenFutureDateAlert()
    }

	func complete(tracker: Tracker) throws {
		try self.checkCurrentDate()
		self.analyticsService.didTapTracker()
		self.trackersCompletingService.completeTracker(trackerId: tracker.id, date: currentDate)
	}

	func incomplete(tracker: Tracker) throws {
		try self.checkCurrentDate()
		self.analyticsService.didTapTracker()
		self.trackersCompletingService.incompleteTracker(trackerId: tracker.id, date: currentDate)
	}
}

// MARK: - TrackersDataProviderDelegate
extension TrackersViewPresenter: TrackersDataProviderDelegate {
	func insertSections(at: IndexSet) {
		self.view?.insertSections(at: at)
	}

	func deleteSections(at: IndexSet) {
		self.view?.deleteSections(at: at)
	}

	func reloadSections(at: IndexSet) {
		self.view?.reloadSections(at: at)
	}

	func insertItems(at: [IndexPath]) {
		self.view?.insertItems(at: at)
	}

	func deleteItems(at: [IndexPath]) {
		self.view?.deleteItems(at: at)
	}

	func moveItems(at: IndexPath, to: IndexPath) {
		self.view?.moveItems(at: at, to: to)
	}

	func reloadItems(at: [IndexPath]) {
		self.view?.reloadItems(at: at)
		self.fetchCompletedTrackersForCurrentDate()
	}

	func didChangeContent(operations: [BlockOperation]) {
		self.trackers = self.trackersService.trackers
		self.view?.didChangeContentAnimated(operations: operations)
	}

	func fetchDidPerformed() {
		self.updateTrackers()
	}
}

// MARK: - TrackersRecordServiceDelegate
extension TrackersViewPresenter: TrackersRecordServiceDelegate {
	func didRecieveCompletedTrackers(_ records: [TrackerRecord]) {
		self.completedTrackersRecords = Set(records)
	}
}

private extension TrackersViewPresenter {
	var isCurrentDateLaterThanToday: Bool {
		self.currentDate > Date()
	}

	func checkCurrentDate() throws {
		if self.isCurrentDateLaterThanToday {
			self.requestChosenFutureDateAlert()
			throw TrackersViewPresenterError.currentDateLaterThanToday
		}
	}

	func fetchCompletedTrackersForCurrentDate() {
		self.trackersRecordService.fetchCompletedRecords(for: self.currentDate)
	}

	func updateTrackers() {
		self.trackers = self.trackersService.trackers
		DispatchQueue.main.async { [weak self] in
			self?.view?.didRecieveTrackers()
		}
	}
}
