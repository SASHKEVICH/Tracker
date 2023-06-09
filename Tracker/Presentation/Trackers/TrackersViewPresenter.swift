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
    
    func complete(tracker: Tracker) throws
    func incomplete(tracker: Tracker) throws
}

protocol TrackersViewPresetnerSearchControllerProtocol: AnyObject {
    func requestFilteredTrackers(for searchText: String?)
    func requestShowAllCategoriesForCurrentDay()
}

protocol TrackersViewPresenterProtocol: AnyObject {
    var view: TrackersViewControllerProtocol? { get set }
    var collectionHelper: TrackersViewPresenterCollectionViewHelperProtocol { get }
    var searchControllerHelper: TrackersViewPresenterSearchControllerHelperProtocol { get }
    var currentDate: Date { get }
    func requestTrackers(for date: Date)
    func viewDidLoad()
	func navigateToTrackerTypeScreen()
}

// MARK: - TrackersViewPresenter
final class TrackersViewPresenter {
    enum TrackersViewPresenterError: Error {
        case currentDateLaterThanToday
    }
    
    private enum TrackersViewPresenterState {
        case search
        case normal
    }

	weak var view: TrackersViewControllerProtocol?
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
    
    private var trackersService: TrackersServiceProtocol
	private let trackersCompletingService: TrackersCompletingServiceProtocol
	private let trackersRecordService: TrackersRecordServiceProtocol
	private let router: TrackersViewRouterProtocol
    
    private var state: TrackersViewPresenterState = .normal
    
	init(
		trackersService: TrackersServiceProtocol,
		trackersCompletingService: TrackersCompletingServiceProtocol,
		trackersRecordService: TrackersRecordServiceProtocol,
		router: TrackersViewRouterProtocol
	) {
        self.trackersService = trackersService
		self.trackersCompletingService = trackersCompletingService
		self.trackersRecordService = trackersRecordService
		self.router = router
        self.trackersService.trackersDataProviderDelegate = self
    }
}

// MARK: - TrackersViewPresenterProtocol
extension TrackersViewPresenter: TrackersViewPresenterProtocol {
	func requestTrackers(for date: Date) {
		guard let weekDay = date.weekDay else { return }
		self.currentDate = date
		self.state = .normal

		self.trackersService.fetchTrackers(weekDay: weekDay)
		self.fetchCompletedTrackersForCurrentDate()
	}

	func viewDidLoad() {
		self.fetchCompletedTrackersForCurrentDate()
	}

	func navigateToTrackerTypeScreen() {
		self.router.navigateToTrackerTypeScreen()
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
		self.requestTrackers(for: currentDate)
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
		self.trackersService.tracker(at: indexPath)
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String? {
		self.trackersService.categoryTitle(at: indexPath)
    }
    
    func completedTimesCount(trackerId: UUID) -> Int {
		self.trackersRecordService.completedTimesCount(trackerId: trackerId)
    }
    
    func didRecievedEmptyTrackers() {
        switch state {
        case .normal:
			self.view?.showPlaceholderViewForCurrentDay()
        case .search:
			self.view?.showPlaceholderViewForEmptySearch()
        }
    }
    
    func didRecievedNonEmptyTrackers() {
		self.view?.shouldHidePlaceholderView(true)
    }
    
    func requestChosenFutureDateAlert() {
        let alertPresenter = AlertPresenterService(delegate: view)
        let alertModel = AlertModel(
            title: "Некорректная дата",
            message: "Вы отмечаете трекер в будущем >:[",
            actionTitles: ["OK"])
		alertPresenter.requestAlert(alertModel)
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
extension TrackersViewPresenter: TrackersDataProviderDelegate {
    func didUpdate(update: TrackersStoreUpdate) {
        view?.didRecieveTrackers()
    }
    
    func didRecievedTrackers() {
        DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.requestTrackers(for: self.currentDate)
            self.view?.didRecieveTrackers()
        }
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
		let completedTrackersForCurrentDate = self.trackersRecordService.fetchCompletedRecords(date: currentDate)
		self.completedTrackersRecords = Set(completedTrackersForCurrentDate)
	}
}
