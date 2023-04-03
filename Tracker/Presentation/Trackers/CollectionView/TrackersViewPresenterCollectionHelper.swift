//
//  TrackersViewPresenterCollectionHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 03.04.2023.
//

import UIKit

protocol TrackersViewPresenterCollectionHelperProtocol: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var presenter: TrackersViewPresenterProtocol? { get set }
}

final class TrackersViewPresenterCollectionHelper: NSObject, TrackersViewPresenterCollectionHelperProtocol {
    var presenter: TrackersViewPresenterProtocol?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let presenter = presenter else {
            assertionFailure("Presenter is nil")
            return 0
        }
        return presenter.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        UICollectionViewCell()
    }
}
