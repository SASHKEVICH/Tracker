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
    weak var presenter: TrackersViewPresenterProtocol?
    private let collectionViewConstants = TrackerCollectionViewConstants.configuration
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let leftInset = collectionViewConstants.collectionViewInsets.left
        let rightInset = collectionViewConstants.collectionViewInsets.right
        let horizontalCellSpacing = collectionViewConstants.horizontalCellSpacing
        return CGSize(width: (collectionView.bounds.width - (leftInset + rightInset + horizontalCellSpacing)) / 2, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        collectionViewConstants.horizontalCellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        collectionViewConstants.verticalCellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        collectionViewConstants.collectionViewInsets
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let presenter = presenter else {
            assertionFailure("Presenter is nil")
            return 0
        }
        return presenter.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackerCollectionViewCell
        cell?.tracker = presenter?.trackers[indexPath.row]
        return cell ?? UICollectionViewCell()
    }
}
