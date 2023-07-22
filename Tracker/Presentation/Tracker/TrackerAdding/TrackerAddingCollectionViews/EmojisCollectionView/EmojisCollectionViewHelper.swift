//
//  ColorsCollectionViewHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 26.04.2023.
//

import UIKit

protocol TrackerEmojisCollectionViewDelegate: AnyObject {
    var selectedEmoji: String? { get }
    func didSelect(emoji: String)
}

protocol EmojisCollectionViewHelperProtocol: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var delegate: TrackerEmojisCollectionViewDelegate? { get set }
}

final class EmojisCollectionViewHelper: NSObject, EmojisCollectionViewHelperProtocol {
    weak var delegate: TrackerEmojisCollectionViewDelegate?

    private let configuration = TrackerCollectionViewConstants.addTrackerCollectionsConfiguration
    private let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🌴", "😪",
    ]
}

// MARK: UICollectionViewDelegateFlowLayout

extension EmojisCollectionViewHelper {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EmojisCollectionViewCell,
              let emoji = cell.emoji
        else { return }

        self.delegate?.didSelect(emoji: emoji)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt _: IndexPath
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
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt _: Int
    ) -> CGFloat {
        self.configuration.horizontalCellSpacing
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumLineSpacingForSectionAt _: Int
    ) -> CGFloat {
        self.configuration.verticalCellSpacing
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        insetForSectionAt _: Int
    ) -> UIEdgeInsets {
        self.configuration.collectionViewInsets
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        referenceSizeForHeaderInSection _: Int
    ) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 50)
    }
}

// MARK: UICollectionViewDataSource

extension EmojisCollectionViewHelper {
    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection _: Int
    ) -> Int {
        self.emojis.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojisCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? EmojisCollectionViewCell
        else {
            assertionFailure("cannot dequeue emojis cell")
            return UICollectionViewCell()
        }
        let emoji = self.emojis[indexPath.row]
        cell.emoji = emoji

        guard let selectedEmoji = self.delegate?.selectedEmoji, selectedEmoji == emoji else { return cell }
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackersCollectionSectionHeader.reuseIdentifier,
            for: indexPath
        ) as? TrackersCollectionSectionHeader
        else {
            assertionFailure("Cannot dequeue header view")
            return UICollectionReusableView()
        }
        view.headerText = "Emoji"
        return view
    }
}
