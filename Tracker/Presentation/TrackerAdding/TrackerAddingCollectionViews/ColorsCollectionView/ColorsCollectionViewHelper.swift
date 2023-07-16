//
//  ColorCollectionViewHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 27.04.2023.
//

import UIKit

protocol TrackerColorCollectionViewDelegate: AnyObject {
	var selectedColor: UIColor? { get }
	func didSelect(color: UIColor)
}

protocol ColorsCollectionViewHelperProtocol: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var delegate: TrackerColorCollectionViewDelegate? { get set }
}

final class ColorsCollectionViewHelper: NSObject, ColorsCollectionViewHelperProtocol {
    weak var delegate: TrackerColorCollectionViewDelegate?
    
    private let configuration = TrackerCollectionViewConstants.addTrackerCollectionsConfiguration
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
        guard let cell = collectionView.cellForItem(at: indexPath) as? ColorsCollectionViewCell,
			  let color = cell.color
        else { return }
        
		self.delegate?.didSelect(color: color)
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
		self.configuration.horizontalCellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
		self.configuration.verticalCellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
		self.configuration.collectionViewInsets
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
		CGSize(width: collectionView.frame.width, height: 50)
    }
}

// MARK: UICollectionViewDataSource
extension ColorsCollectionViewHelper {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
		self.colors.count
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
		let color = self.colors[indexPath.row]
		cell.color = color

		guard let selectedColor = self.delegate?.selectedColor, selectedColor == color else { return cell }
		cell.isSelected = true

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
            for: indexPath) as? TrackersCollectionSectionHeader
        else {
            assertionFailure("Cannot dequeue header view")
            return UICollectionReusableView()
        }
		view.headerText = R.string.localizable.trackerAddingColorCollectionViewHeaderTitle()
        return view
    }
}
