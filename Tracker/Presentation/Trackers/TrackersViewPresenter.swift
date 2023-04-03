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
        
        collectionHelper = TrackersViewPresenterCollectionHelper()
    }
    
    func requestTrackers() {
        let tracker = Tracker(id: UUID(), title: "Тестовая привычка", color: .green, emoji: "🤬", schedule: [WeekDay.monday])
        trackers.append(tracker)
        view?.didRecieveTrackers()
    }
}
