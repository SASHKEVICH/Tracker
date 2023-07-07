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
    var collectionHelper: TrackersViewPresenterCollectionViewHelperProtocol? { get }
    var searchControllerHelper: TrackersViewPresenterSearchControllerHelperProtocol? { get }
    var currentDate: Date { get }
    func requestTrackers(for date: Date)
    func viewDidLoad()
}

typealias TrackersViewPresenterFullProtocol =
    TrackersViewPresenterProtocol
    & TrackersViewPresetnerCollectionViewProtocol
    & TrackersViewPresetnerSearchControllerProtocol

// MARK: - TrackersViewPresenter
final class TrackersViewPresenter: TrackersViewPresenterProtocol {
    enum TrackersViewPresenterError: Error {
        case currentDateLaterThanToday
    }
    
    private enum TrackersViewPresenterState {
        case search
        case normal
    }

	weak var view: TrackersViewControllerProtocol?
	var collectionHelper: TrackersViewPresenterCollectionViewHelperProtocol?
	var searchControllerHelper: TrackersViewPresenterSearchControllerHelperProtocol?

	var completedTrackersRecords: Set<TrackerRecord> = []
	var currentDate: Date = Date()
    
    private var trackersService: TrackersServiceProtocol
	private let trackersCompletingService: TrackersCompletingServiceProtocol
	private let trackersRecordService: TrackersRecordServiceProtocol
    
    private var state: TrackersViewPresenterState = .normal

	private var isCurrentDateLaterThanToday: Bool {
		guard currentDate > Date() else { return false }
		return true
	}
    
	init(
		trackersService: TrackersServiceProtocol,
		trackersCompletingService: TrackersCompletingServiceProtocol,
		trackersRecordService: TrackersRecordServiceProtocol
	) {
        self.trackersService = trackersService
		self.trackersCompletingService = trackersCompletingService
		self.trackersRecordService = trackersRecordService
        self.trackersService.trackersDataProviderDelegate = self
        
		self.setupCollectionDelegate()
		self.setupSearchControllerDelegate()
    }
}

// MARK: - Requesting trackers
extension TrackersViewPresenter: TrackersViewPresetnerSearchControllerProtocol {
    func requestTrackers(for date: Date) {
        guard let weekDay = date.weekDay else { return }
        self.currentDate = date
        self.state = .normal
        
        DispatchQueue.global().async { [weak self] in
            self?.trackersService.fetchTrackers(weekDay: weekDay)
            self?.fetchCompletedTrackersForCurrentDate()
        }
    }
    
    func requestFilteredTrackers(for searchText: String?) {
        guard let titleSearchString = searchText, let weekDay = currentDate.weekDay else { return }
        self.state = .search
        
        DispatchQueue.global().async { [weak self] in
            self?.trackersService.fetchTrackers(titleSearchString: titleSearchString, currentWeekDay: weekDay)
            self?.fetchCompletedTrackersForCurrentDate()
        }
    }
    
    func viewDidLoad() {
        DispatchQueue.global().async { [weak self] in
            self?.fetchCompletedTrackersForCurrentDate()
        }
    }
    
    func requestShowAllCategoriesForCurrentDay() {
        requestTrackers(for: currentDate)
    }
    
    private func fetchCompletedTrackersForCurrentDate() {
        let completedTrackersForCurrentDate = trackersRecordService.fetchCompletedRecords(date: currentDate)
        self.completedTrackersRecords = Set(completedTrackersForCurrentDate)
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

	private func checkCurrentDate() throws {
		if self.isCurrentDateLaterThanToday {
			self.requestChosenFutureDateAlert()
			throw TrackersViewPresenterError.currentDateLaterThanToday
		}
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

// MARK: - Setup delegates
private extension TrackersViewPresenter {
    func setupCollectionDelegate() {
        let collectionHelper = TrackersViewPresenterCollectionHelper()
        collectionHelper.presenter = self
        self.collectionHelper = collectionHelper
    }
    
    func setupSearchControllerDelegate() {
        let searchControllerHelper = TrackersViewPresenterSearchControllerHelper()
        searchControllerHelper.presenter = self
        self.searchControllerHelper = searchControllerHelper
    }
}
