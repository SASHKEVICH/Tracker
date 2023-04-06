//
//  TrackersViewPresenter.swift
//  Tracker
//
//  Created by Александр Бекренев on 02.04.2023.
//

import Foundation

protocol TrackersViewPresenterProtocol: AnyObject {
    var view: TrackersViewControllerProtocol? { get set }
    var collectionHelper: TrackersViewPresenterCollectionHelperProtocol? { get set }
    var trackers: [Tracker] { get }
    var categories: [TrackerCategory] { get }
    func requestTrackers()
}

final class TrackersViewPresenter: NSObject, TrackersViewPresenterProtocol {
    weak var view: TrackersViewControllerProtocol?
    var collectionHelper: TrackersViewPresenterCollectionHelperProtocol?
    
    var trackers: [Tracker] = []
    var categories: [TrackerCategory] = []
    
    override init() {
        super.init()
        
        setupCollectionHelper()
    }
    
    func requestTrackers() {
        let newCategories = [
            TrackerCategory(title: "Категория 1", trackers: [
                Tracker(id: UUID(), title: "Тестовая привычка 1", color: .trackerColorSelection5, emoji: "🤬", schedule: [WeekDay.monday]),
                Tracker(id: UUID(), title: "Тестовая привычка 2", color: .trackerBlue, emoji: "🤯", schedule: [WeekDay.monday]),
            ]),
            TrackerCategory(title: "Категория 2", trackers: [
                Tracker(id: UUID(), title: "Тестовая привычка 1", color: .trackerColorSelection5, emoji: "🤬", schedule: [WeekDay.monday]),
                Tracker(id: UUID(), title: "Тестовая привычка 2", color: .trackerBlue, emoji: "🤯", schedule: [WeekDay.monday]),
            ])
        ]
        
        categories.append(contentsOf: newCategories)
        view?.didRecieveTrackers()
    }
}

private extension TrackersViewPresenter {
    func setupCollectionHelper() {
        let collectionHelper = TrackersViewPresenterCollectionHelper()
        collectionHelper.presenter = self
        self.collectionHelper = collectionHelper
    }
}
