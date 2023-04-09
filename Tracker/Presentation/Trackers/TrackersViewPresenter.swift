//
//  TrackersViewPresenter.swift
//  Tracker
//
//  Created by Александр Бекренев on 02.04.2023.
//

import Foundation

protocol TrackersViewPresenterProtocol: AnyObject {
    var view: TrackersViewControllerProtocol? { get set }
    var collectionDelegate: TrackersViewPresenterCollectionDelegateProtocol? { get set }
    var currentDate: Date { get set }
    var visibleCategories: [TrackerCategory] { get }
    func requestTrackers(for date: Date)
}

final class TrackersViewPresenter: TrackersViewPresenterProtocol {
    private var trackersService: TrackersServiceProtocol = TrackersService()
    
    weak var view: TrackersViewControllerProtocol?
    var collectionDelegate: TrackersViewPresenterCollectionDelegateProtocol?

    var completedTrackers: [TrackerRecord] = []
    var visibleCategories: [TrackerCategory] = []
    var currentDate: Date = Date()
    
    init() {
        setupCollectionDelegate()
    }
    
    func requestTrackers(for date: Date) {
        self.currentDate = date
        let fetchedCategories = trackersService.fetchTrackers(for: date)
        self.visibleCategories = fetchedCategories
        let indexPaths = getIndexPathsForTrackers()
        view?.didRecieveTrackers(indexPaths: indexPaths)
    }
}

private extension TrackersViewPresenter {
    func setupCollectionDelegate() {
        let collectionDelegate = TrackersViewPresenterCollectionDelegate()
        collectionDelegate.presenter = self
        self.collectionDelegate = collectionDelegate
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
}
