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
    func requestTrackers()
}

final class TrackersViewPresenter: NSObject, TrackersViewPresenterProtocol {
    weak var view: TrackersViewControllerProtocol?
    var collectionHelper: TrackersViewPresenterCollectionHelperProtocol?
    
    var trackers: [Tracker] = []
    
    override init() {
        super.init()
        
        setupCollectionHelper()
    }
    
    func requestTrackers() {
        let newTrackers = [
            Tracker(id: UUID(), title: "Тестовая привычка 1", color: .trackerColorSelection5, emoji: "🤬", schedule: [WeekDay.monday]),
            Tracker(id: UUID(), title: "Тестовая привычка 2", color: .trackerBlue, emoji: "🤯", schedule: [WeekDay.monday]),
        ]
        trackers.append(contentsOf: newTrackers)
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
