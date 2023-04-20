//
//  TrackersViewPresenter.swift
//  Tracker
//
//  Created by Александр Бекренев on 02.04.2023.
//

import Foundation

protocol TrackersViewPresetnerCollectionProtocol: AnyObject {
    var visibleCategories: [TrackerCategory] { get }
    var completedTrackersRecords: Set<TrackerRecord> { get }
    var currentDate: Date { get set }
    func requestChosenFutureDateAlert()
}

protocol TrackersViewPresetnerSearchControllerProtocol: AnyObject {
    func requestFilteredTrackers(for searchText: String?)
    func requestShowAllCategoriesForCurrentDay()
}

protocol TrackersViewPresenterProtocol: AnyObject, TrackersViewPresetnerCollectionProtocol, TrackersViewPresetnerSearchControllerProtocol {
    var view: TrackersViewControllerProtocol? { get set }
    var collectionHelper: TrackersViewPresenterCollectionHelperProtocol? { get }
    var searchControllerHelper: TrackersViewPresenterSearchControllerHelperProtocol? { get }
    func requestTrackers(for date: Date)
}

final class TrackersViewPresenter: TrackersViewPresenterProtocol {
    private let trackersService: TrackersServiceFetchingProtocol & TrackersServiceCompletingProtocol = TrackersService.shared
    private var newTrackerNotifacationObserver: NSObjectProtocol?
    
    weak var view: TrackersViewControllerProtocol?
    var collectionHelper: TrackersViewPresenterCollectionHelperProtocol?
    var searchControllerHelper: TrackersViewPresenterSearchControllerHelperProtocol?

    var completedTrackersRecords: Set<TrackerRecord> = []
    var visibleCategories: [TrackerCategory] = []
    var currentDate: Date = Date()
    
    init() {
        setupCollectionDelegate()
        setupSearchControllerDelegate()
        addNewTrackerNotificationObserver()
    }
}

// MARK: - Requesting trackers
extension TrackersViewPresenter {
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

extension TrackersViewPresenter: TrackersViewPresetnerCollectionProtocol {
    func requestChosenFutureDateAlert() {
        let alertPresenter = AlertPresenterService(delegate: view)
        let alertModel = AlertModel(title: "Некорректная дата", message: "Вы отмечаете трекер в будущем >:[", actionTitles: ["OK"])
        alertPresenter.requestAlert(alertModel)
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
