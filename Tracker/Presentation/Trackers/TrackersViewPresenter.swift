//
//  TrackersViewPresenter.swift
//  Tracker
//
//  Created by Александр Бекренев on 02.04.2023.
//

import Foundation

protocol TrackersViewPresetnerCollectionViewProtocol: AnyObject {
    var visibleCategories: [TrackerCategory] { get }
    var completedTrackersRecords: Set<TrackerRecord> { get }
    var currentDate: Date { get }
    // TODO: var numberOfSections: Int { get }
    // TODO: var numberOfRowsInSection: Int { get }
    // TODO: func object(at indexPath: IndexPath)
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
    var currentDate: Date { get set }
    func requestTrackers(for date: Date)
}

typealias TrackersViewPresenterFullProtocol =
    TrackersViewPresenterProtocol
    & TrackersViewPresetnerCollectionViewProtocol
    & TrackersViewPresetnerSearchControllerProtocol

final class TrackersViewPresenter: TrackersViewPresenterProtocol {
    enum TrackersViewPresenterError: Error {
        case currentDateLaterThanToday
    }
    
    private let trackersService: TrackersServiceFetchingCompletingProtocol & TrackersServiceCompletingProtocol
    private var newTrackerNotifacationObserver: NSObjectProtocol?
    
    weak var view: TrackersViewControllerProtocol?
    var collectionHelper: TrackersViewPresenterCollectionViewHelperProtocol?
    var searchControllerHelper: TrackersViewPresenterSearchControllerHelperProtocol?

    var completedTrackersRecords: Set<TrackerRecord> = []
    var visibleCategories: [TrackerCategory] = []
    var currentDate: Date = Date()
    
    init(trackersService: TrackersServiceFetchingCompletingProtocol) {
        self.trackersService = trackersService
        
        setupCollectionDelegate()
        setupSearchControllerDelegate()
        addNewTrackerNotificationObserver()
    }
}

// MARK: - Requesting trackers
extension TrackersViewPresenter: TrackersViewPresetnerSearchControllerProtocol {
    func requestTrackers(for date: Date) {
        guard let weekDay = date.weekDay else { return }
        let fetchedCategories = trackersService.fetchTrackers(for: weekDay)
        
        self.visibleCategories = fetchedCategories ?? []
        self.completedTrackersRecords = trackersService.completedTrackers
        self.currentDate = date
        
        didRecieveTrackers()
        
        if let fetchedCategories = fetchedCategories, fetchedCategories.isEmpty {
            view?.showPlaceholderViewForCurrentDay()
            return
        }
        view?.showOrHidePlaceholderView(isHide: true)
    }
    
    func requestFilteredTrackers(for searchText: String?) {
        guard let searchText = searchText else { return }
        let categoriesWithDesiredTrackers = trackersService.requestFilterDesiredTrackers(searchText: searchText)
        
        self.visibleCategories = categoriesWithDesiredTrackers
        self.completedTrackersRecords = trackersService.completedTrackers
        
        didRecieveTrackers()
        
        if categoriesWithDesiredTrackers.isEmpty {
            view?.showPlaceholderViewForEmptySearch()
            return
        }
        view?.showOrHidePlaceholderView(isHide: true)
    }
    
    func requestShowAllCategoriesForCurrentDay() {
        requestTrackers(for: currentDate)
    }
}

extension TrackersViewPresenter: TrackersViewPresetnerCollectionViewProtocol {
    func complete(tracker: Tracker) throws {
        if isCurrentDateLaterThanToday { throw TrackersViewPresenterError.currentDateLaterThanToday }
        trackersService.completeTracker(trackerId: tracker.id, date: currentDate)
    }
    
    func incomplete(tracker: Tracker) throws {
        if isCurrentDateLaterThanToday { throw TrackersViewPresenterError.currentDateLaterThanToday }
        trackersService.incompleteTracker(trackerId: tracker.id, date: currentDate)
    }
    
    func requestChosenFutureDateAlert() {
        let alertPresenter = AlertPresenterService(delegate: view)
        let alertModel = AlertModel(
            title: "Некорректная дата",
            message: "Вы отмечаете трекер в будущем >:[",
            actionTitles: ["OK"])
        alertPresenter.requestAlert(alertModel)
    }
    
    private var isCurrentDateLaterThanToday: Bool {
        guard currentDate > Date() else { return false }
        requestChosenFutureDateAlert()
        return true
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

private extension TrackersViewPresenter {
    func didRecieveTrackers() {
        let indexPaths = getIndexPathsForTrackers()
        view?.didRecieveTrackers(indexPaths: indexPaths)
    }
    
    func getIndexPathsForTrackers() -> [IndexPath]? {
        let indexPaths = visibleCategories.enumerated().flatMap { categoryIndex, category in
            let enumeratedTrackers = category.trackers.enumerated()
            return enumeratedTrackers.map { trackerIndex, _ in
                IndexPath(row: trackerIndex, section: categoryIndex)
            }
        }
        return indexPaths
    }
    
    func addNewTrackerNotificationObserver() {
        newTrackerNotifacationObserver = NotificationCenter.default
            .addObserver(
                forName: AddTrackerViewPresenter.didAddTrackerNotificationName,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.requestTrackers(for: self.currentDate)
            }
    }
}
