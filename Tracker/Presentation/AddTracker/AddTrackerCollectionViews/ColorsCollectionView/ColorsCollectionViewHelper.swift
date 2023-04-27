//
//  ColorCollectionViewHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 27.04.2023.
//

import UIKit

protocol ColorsCollectionViewHelperProtocol: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var presenter: AddTrackerViewPresenterCollectionColorsViewHelperProtocol? { get set }
}

final class ColorsCollectionViewHelper: NSObject, ColorsCollectionViewHelperProtocol {
    weak var presenter: AddTrackerViewPresenterCollectionColorsViewHelperProtocol?
    
    private let colors: [UIColor] = [
        .trackerColorSelection1, .trackerColorSelection2, .trackerColorSelection3,
        .trackerColorSelection4, .trackerColorSelection5, .trackerColorSelection6,
        .trackerColorSelection7, .trackerColorSelection8, .trackerColorSelection9,
        .trackerColorSelection10, .trackerColorSelection11, .trackerColorSelection12,
        .trackerColorSelection13, .trackerColorSelection14, .trackerColorSelection15,
        .trackerColorSelection16, .trackerColorSelection17, .trackerColorSelection18
    ]
}

// MARK: UICollectionViewDataSource
extension ColorsCollectionViewHelper {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        colors.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorsCollectionViewCell.identifier,
            for: indexPath) as? ColorsCollectionViewCell
        else {
            assertionFailure("cannot dequeue colors cell")
            return UICollectionViewCell()
        }
        
        cell.color = colors[indexPath.row]
        
        return cell
    }
}
