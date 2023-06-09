//
//  ColorCollectionViewHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 27.04.2023.
//

import UIKit

protocol ColorsCollectionViewHelperProtocol: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var presenter: TrackerAddingViewPresenterCollectionColorsViewHelperProtocol? { get set }
}

final class ColorsCollectionViewHelper: NSObject, ColorsCollectionViewHelperProtocol {
    weak var presenter: TrackerAddingViewPresenterCollectionColorsViewHelperProtocol?
    
    private var configuration = TrackerCollectionViewConstants.addTrackerCollectionsConfiguration

	private let colors: [UIColor] = [
		.Selection.color1, .Selection.color2, .Selection.color3,
		.Selection.color4, .Selection.color5, .Selection.color6,
		.Selection.color7, .Selection.color8, .Selection.color9,
		.Selection.color10, .Selection.color11, .Selection.color12,
		.Selection.color13, .Selection.color14, .Selection.color15,
		.Selection.color16, .Selection.color17, .Selection.color18,
	]
}

// MARK: UICollectionViewDelegateFlowLayout
extension ColorsCollectionViewHelper {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? ColorsCollectionViewCell,
            let color = cell.color
        else {
            return
        }
        
        presenter?.didSelect(color: color)
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
            withReuseIdentifier: ColorsCollectionViewCell.reuseIdentifier,
            for: indexPath) as? ColorsCollectionViewCell
        else {
            assertionFailure("cannot dequeue colors cell")
            return UICollectionViewCell()
        }
        
        cell.color = colors[indexPath.row]
        
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
        
        view.headerText = "Цвет"
        return view
    }
}
