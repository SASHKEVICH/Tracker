//
//  TrackersViewPresenterCollectionHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 03.04.2023.
//

import UIKit

protocol TrackersViewPresenterCollectionHelperCellDelegate {
    func didTapCompleteCellButton(_ cell: TrackersCollectionViewCell)
}

protocol TrackersViewPresenterCollectionViewHelperProtocol: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var presenter: TrackersViewPresetnerCollectionViewProtocol? { get set }
}

final class TrackersViewPresenterCollectionHelper: NSObject, TrackersViewPresenterCollectionViewHelperProtocol {
    weak var presenter: TrackersViewPresetnerCollectionViewProtocol?
    private let collectionViewConstants = TrackerCollectionViewConstants.trackersCollectionConfiguration
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewPresenterCollectionHelper {
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 18)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewPresenterCollectionHelper {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let presenter = presenter else {
            assertionFailure("Presenter is nil")
            return 0
        }
        return presenter.visibleCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let presenter = presenter else {
            assertionFailure("Presenter is nil")
            return 0
        }
        return presenter.visibleCategories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier,
                for: indexPath) as? TrackersCollectionViewCell,
            let presenter = presenter
        else {
            assertionFailure("Cannot dequeue cell or presenter is nil")
            return UICollectionViewCell()
        }
        
        let section = presenter.visibleCategories[indexPath.section]
        let tracker = section.trackers[indexPath.row]
        
        cell.tracker = tracker
        let doesTrackerStoredInCompletedTrackersForCurrentDate = presenter
            .completedTrackersRecords
            .first(where: { $0.trackerId == tracker.id && $0.date.isDayEqualTo(presenter.currentDate) }) != nil
              
        if doesTrackerStoredInCompletedTrackersForCurrentDate {
            cell.state = .completed
            
            let dayCount = presenter.completedTrackersRecords
                .filter { $0.trackerId == tracker.id }
                .count
            cell.dayCount = dayCount
        }
        
        cell.delegate = self
        
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
        
        view.headerText = presenter?.visibleCategories[indexPath.section].title
        return view
    }
}

// MARK: - Complete cell button handler
extension TrackersViewPresenterCollectionHelper: TrackersViewPresenterCollectionHelperCellDelegate {
    func didTapCompleteCellButton(_ cell: TrackersCollectionViewCell) {
        guard let tracker = cell.tracker else { return }
        
        if cell.state == .completed {
            guard let _ = try? presenter?.incomplete(tracker: tracker) else { return }
            cell.dayCount -= 1
        } else {
            guard let _ = try? presenter?.complete(tracker: tracker) else { return }
            cell.dayCount += 1
        }
        
        cell.state = cell.state == .completed ? .incompleted : .completed
    }
}
