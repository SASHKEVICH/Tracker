//
//  ColorsCollectionViewHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 26.04.2023.
//

import UIKit

protocol EmojisCollectionViewHelperProtocol: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var presenter: AddTrackerViewPresenterEmojisCollectionViewHelperProtocol? { get set }
}

final class EmojisCollectionViewHelper: NSObject, EmojisCollectionViewHelperProtocol {
    weak var presenter: AddTrackerViewPresenterEmojisCollectionViewHelperProtocol?
    
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
        print("tap")
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
            withReuseIdentifier: EmojisCollectionViewCell.identifier,
            for: indexPath) as? EmojisCollectionViewCell
        else {
            assertionFailure("cannot dequeue emojis cell")
            return UICollectionViewCell()
        }
        
        cell.emoji = emojis[indexPath.row]
        
        return cell
    }
}
