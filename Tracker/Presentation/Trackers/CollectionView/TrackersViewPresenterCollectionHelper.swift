//
//  TrackersViewPresenterCollectionHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 03.04.2023.
//

import UIKit

protocol TrackersViewPresenterCollectionDelegateProtocol: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var presenter: TrackersViewPresetnerCollectionProtocol? { get set }
}

final class TrackersViewPresenterCollectionHelper: NSObject, TrackersViewPresenterCollectionDelegateProtocol {
    weak var presenter: TrackersViewPresetnerCollectionProtocol?
    private let collectionViewConstants = TrackerCollectionViewConstants.configuration
    private let trackersService: TrackersServiceProtocol = TrackersService.shared
    
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
//        let indexPath = IndexPath(row: 0, section: section)
//        let headerView = self.collectionView(
//            collectionView,
//            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
//            at: indexPath)
//        let size = headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
//                                                             height: UIView.layoutFittingExpandedSize.height),
//                                                             withHorizontalFittingPriority: .required,
//                                                             verticalFittingPriority: .fittingSizeLevel)
//        return size
//
        // Почему-то вылезает ошибка при UIView.layoutFittingExpandedSize.height
        CGSize(width: collectionView.frame.width, height: 51)
    }
    
    // MARK: - UICollectionViewDataSource
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
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier,
            for: indexPath) as? TrackersCollectionViewCell
        let section = presenter?.visibleCategories[indexPath.section]
        let tracker = section?.trackers[indexPath.row]
        
        cell?.tracker = tracker
        let doesTrackerStoredInCompletedTrackers = presenter?.completedTrackersRecords.first(where: { $0.trackerId == tracker?.id }) != nil
              
        if doesTrackerStoredInCompletedTrackers {
            cell?.state = .completed
            
            let dayCount = presenter?.completedTrackersRecords
                .filter { $0.trackerId == tracker?.id }
                .count
            cell?.dayCount = dayCount ?? -1
        }
        
        cell?.completeTrackerButton.addTarget(
            self,
            action: #selector(didTapCompleteCellButton(_:)),
            for: .touchUpInside)
        
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackersCollectionSectionHeader.identifier,
            for: indexPath) as? TrackersCollectionSectionHeader
        view?.headerText = presenter?.visibleCategories[indexPath.section].title
        return view ?? UICollectionReusableView()
    }
}

// MARK: - Complete cell button handler
private extension TrackersViewPresenterCollectionHelper {
    @objc
    func didTapCompleteCellButton(_ sender: UIButton) {
        guard
            let contentView = sender.superview,
            let cell = contentView.superview as? TrackersCollectionViewCell,
            let tracker = cell.tracker,
            let currentDate = presenter?.currentDate
        else { return }
        
        guard currentDate <= Date() else {
            presenter?.requestChosenFutureDateAlert()
            return
        }
        
        cell.state = cell.state == .completed ? .incompleted : .completed
        
        if cell.state == .completed {
            cell.dayCount += 1
            trackersService.completeTracker(trackerId: tracker.id, date: currentDate)
        } else {
            cell.dayCount -= 1
            trackersService.incompleteTracker(trackerId: tracker.id, date: currentDate)
        }
    }
}
