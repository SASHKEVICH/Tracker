//
//  ColorsCollectionViewHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 26.04.2023.
//

import UIKit

protocol EmojisCollectionViewHelperProtocol: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var presenter: TrackerAddingViewPresenterEmojisCollectionViewHelperProtocol? { get set }
}

final class EmojisCollectionViewHelper: NSObject, EmojisCollectionViewHelperProtocol {
    weak var presenter: TrackerAddingViewPresenterEmojisCollectionViewHelperProtocol?
    
    private let configuration = TrackerCollectionViewConstants.addTrackerCollectionsConfiguration
    
    private let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🌴", "😪"
    ]
}

// MARK: UICollectionViewDelegateFlowLayout
extension EmojisCollectionViewHelper {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? EmojisCollectionViewCell,
            let emoji = cell.emoji
        else {
            return
        }
        
        presenter?.didSelect(emoji: emoji)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let leftInset = configuration.collectionViewInsets.left
        let rightInset = configuration.collectionViewInsets.right
        let horizontalCellSpacing = configuration.horizontalCellSpacing
        
        let cellsPerRow: CGFloat = 6
        let cellsHorizontalSpace = leftInset + rightInset + horizontalCellSpacing * cellsPerRow
        
        let width = (collectionView.bounds.width - cellsHorizontalSpace) / cellsPerRow
        return CGSize(width: width, height: width)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        configuration.horizontalCellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        configuration.verticalCellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        configuration.collectionViewInsets
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 18)
    }
}

// MARK: UICollectionViewDataSource
extension EmojisCollectionViewHelper {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        emojis.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojisCollectionViewCell.reuseIdentifier,
            for: indexPath) as? EmojisCollectionViewCell
        else {
            assertionFailure("cannot dequeue emojis cell")
            return UICollectionViewCell()
        }
        
        cell.emoji = emojis[indexPath.row]
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackersCollectionSectionHeader.identifier,
            for: indexPath) as? TrackersCollectionSectionHeader
        else {
            assertionFailure("Cannot dequeue header view")
            return UICollectionReusableView()
        }
        
        view.headerText = "Emoji"
        return view
    }
}
