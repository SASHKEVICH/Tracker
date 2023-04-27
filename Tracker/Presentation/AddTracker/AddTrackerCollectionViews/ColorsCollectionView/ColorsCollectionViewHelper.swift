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
    
    private var configuration = TrackerCollectionViewConstants.addTrackerCollectionsConfiguration
    
    private let colors: [UIColor] = [
        .trackerColorSelection1, .trackerColorSelection2, .trackerColorSelection3,
        .trackerColorSelection4, .trackerColorSelection5, .trackerColorSelection6,
        .trackerColorSelection7, .trackerColorSelection8, .trackerColorSelection9,
        .trackerColorSelection10, .trackerColorSelection11, .trackerColorSelection12,
        .trackerColorSelection13, .trackerColorSelection14, .trackerColorSelection15,
        .trackerColorSelection16, .trackerColorSelection17, .trackerColorSelection18
    ]
}

// MARK: UICollectionViewDelegateFlowLayout
extension ColorsCollectionViewHelper {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        print("tap")
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
