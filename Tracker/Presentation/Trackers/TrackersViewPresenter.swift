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
    var collectionDelegate: TrackersViewPresenterCollectionDelegateProtocol? { get }
    var searchControllerDelegate: TrackersViewPresenterSearchControllerDelegateProtocol? { get }
    func requestTrackers(for date: Date)
}

final class TrackersViewPresenter: TrackersViewPresenterProtocol {
    private let trackersService: TrackersServiceProtocol = TrackersService.shared
    
    weak var view: TrackersViewControllerProtocol?
    var collectionDelegate: TrackersViewPresenterCollectionDelegateProtocol?
    var searchControllerDelegate: TrackersViewPresenterSearchControllerDelegateProtocol?

    var completedTrackersRecords: Set<TrackerRecord> = []
    var visibleCategories: [TrackerCategory] = []
    var currentDate: Date = Date()
    
    init() {
        setupCollectionDelegate()
        setupSearchControllerDelegate()
    }
}

// MARK: - Requesting trackers
extension TrackersViewPresenter {
    func requestTrackers(for date: Date) {
        let fetchedCategories = trackersService.fetchTrackers(for: date)
        
        self.visibleCategories = fetchedCategories
        self.completedTrackersRecords = trackersService.completedTrackers
        self.currentDate = date
        
        let indexPaths = getIndexPathsForTrackers()
        view?.didRecieveTrackers(indexPaths: indexPaths)
        
        if fetchedCategories.isEmpty {
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
        
        let indexPaths = getIndexPathsForTrackers()
        view?.didRecieveTrackers(indexPaths: indexPaths)
        
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
        let collectionDelegate = TrackersViewPresenterCollectionDelegate()
        collectionDelegate.presenter = self
        self.collectionDelegate = collectionDelegate
    }
    
    func setupSearchControllerDelegate() {
        let searchControllerDelegate = TrackersViewPresenterSearchControllerDelegate()
        searchControllerDelegate.presenter = self
        self.searchControllerDelegate = searchControllerDelegate
    }
}

private extension TrackersViewPresenter {
    func getIndexPathsForTrackers() -> [IndexPath]? {
        let indexPaths = visibleCategories.enumerated().flatMap { categoryIndex, category in
            let enumeratedTrackers = category.trackers.enumerated()
            return enumeratedTrackers.map { trackerIndex, _ in
                IndexPath(row: trackerIndex, section: categoryIndex)
            }
        }
        return indexPaths
    }
}
