//
//  TrackersViewPresenter.swift
//  Tracker
//
//  Created by Александр Бекренев on 02.04.2023.
//

import Foundation

protocol TrackersViewPresetnerCollectionProtocol {
    var visibleCategories: [TrackerCategory] { get }
    var completedTrackersRecords: Set<TrackerRecord> { get }
}

protocol TrackersViewPresetnerSearchControllerProtocol: AnyObject {
    func requestFilteredTrackers(for searchText: String?)
    func requestShowAllCategoriesForCurrentDay()
}

protocol TrackersViewPresenterProtocol: AnyObject, TrackersViewPresetnerCollectionProtocol, TrackersViewPresetnerSearchControllerProtocol {
    var view: TrackersViewControllerProtocol? { get set }
    var collectionDelegate: TrackersViewPresenterCollectionDelegateProtocol? { get }
    var searchControllerDelegate: TrackersViewPresenterSearchControllerDelegateProtocol? { get }
    var currentDate: Date { get set }
    func requestTrackers(for date: Date)
}

final class TrackersViewPresenter: TrackersViewPresenterProtocol {
    private var trackersService: TrackersServiceProtocol = TrackersService()
    
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
    
    func requestTrackers(for date: Date) {
        let fetchedCategories = trackersService.fetchTrackers(for: date)
        self.visibleCategories = fetchedCategories
        self.currentDate = date
        self.completedTrackersRecords = trackersService.completedTrackers
        
        let indexPaths = getIndexPathsForTrackers()
        view?.didRecieveTrackers(indexPaths: indexPaths)
    }
}

extension TrackersViewPresenter {
    func requestFilteredTrackers(for searchText: String?) {
        guard let searchText = searchText else { return }
//         TODO: let filteredTrackers = trackersService.requestFilteredTrackers(for: searchText)
        let categoriesWithDesiredTrackers = trackersService.requestFilterDesiredTrackers(searchText: searchText)
        self.visibleCategories = categoriesWithDesiredTrackers
        self.completedTrackersRecords = trackersService.completedTrackers
        
        let indexPaths = getIndexPathsForTrackers()
        view?.didRecieveTrackers(indexPaths: indexPaths)
        // TODO: self.visibleCategories = filteredTrackers
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
