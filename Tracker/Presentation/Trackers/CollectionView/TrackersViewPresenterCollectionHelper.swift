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
		let leftInset = self.collectionViewConstants.collectionViewInsets.left
		let rightInset = self.collectionViewConstants.collectionViewInsets.right
		let horizontalCellSpacing = self.collectionViewConstants.horizontalCellSpacing
        return CGSize(width: (collectionView.bounds.width - (leftInset + rightInset + horizontalCellSpacing)) / 2, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
		self.collectionViewConstants.horizontalCellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
		self.collectionViewConstants.verticalCellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
		self.collectionViewConstants.collectionViewInsets
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

        return presenter.numberOfItemsInSection(section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
		guard let presenter = self.presenter else {
            assertionFailure("Presenter is nil")
            return 0
        }

        if presenter.numberOfSections == 0 {
            presenter.didRecievedEmptyTrackers()
        } else {
            presenter.didRecievedNonEmptyTrackers()
        }
        
        return presenter.numberOfSections
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier,
			for: indexPath) as? TrackersCollectionViewCell,
			  let presenter = self.presenter,
			  let tracker = presenter.tracker(at: indexPath)
        else {
            assertionFailure("Cannot dequeue cell or presenter is nil")
            return UICollectionViewCell()
        }

        cell.tracker = tracker

		let currentDate = presenter.currentDate
		let completedTrackerForCurrentDay = presenter.completedTrackersRecords.first {
			$0.trackerId == tracker.id && $0.date.isDayEqualTo(currentDate)
		}
              
        if completedTrackerForCurrentDay != nil {
            cell.state = .completed
        }

		cell.dayCount = self.completedTimesCount(trackerId: tracker.id)
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
        
		view.headerText = self.presenter?.categoryTitle(at: indexPath)
        return view
    }
}

// MARK: - Complete cell button handler
extension TrackersViewPresenterCollectionHelper: TrackersViewPresenterCollectionHelperCellDelegate {
    func didTapCompleteCellButton(_ cell: TrackersCollectionViewCell) {
        guard let tracker = cell.tracker else { return }
		guard let presenter = self.presenter else { return }
        
        if cell.state == .completed {
            guard let _ = try? presenter.incomplete(tracker: tracker) else { return }
        } else {
            guard let _ = try? presenter.complete(tracker: tracker) else { return }
        }
        
		cell.dayCount = self.completedTimesCount(trackerId: tracker.id)
        cell.state = cell.state == .completed ? .incompleted : .completed
    }
}

private extension TrackersViewPresenterCollectionHelper {
	func completedTimesCount(trackerId: UUID) -> String {
		guard let presenter = self.presenter else {
			assertionFailure("presenter is nil")
			return ""
		}

		let times = presenter.completedTimesCount(trackerId: trackerId)
		let dayCount = R.string.localizable.stringKey(times: times)
		return dayCount
	}
}
