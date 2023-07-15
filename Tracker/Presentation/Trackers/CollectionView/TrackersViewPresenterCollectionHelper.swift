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
		CGSize(width: collectionView.frame.width, height: 50)
    }

	func collectionView(
		_ collectionView: UICollectionView,
		contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
		point: CGPoint
	) -> UIContextMenuConfiguration? {
		guard indexPaths.count > 0 else { return nil }

		let indexPath = indexPaths[0]

		guard let cell = collectionView.cellForItem(at: indexPath) as? TrackersCollectionViewCell else {
			return nil
		}

		guard let contextActions = self.prepareContextActions(for: cell) else { return nil }
		return UIContextMenuConfiguration(actionProvider: { actions in
			return UIMenu(children: contextActions)
		})
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
			for: indexPath
		) as? TrackersCollectionViewCell,
			  let presenter = self.presenter,
			  let tracker = presenter.tracker(at: indexPath)
        else {
            assertionFailure("Cannot dequeue cell or presenter is nil")
            return UICollectionViewCell()
        }

        cell.tracker = tracker

		let currentDate = presenter.currentDate
		let isTrackerCompletedForCurrentDay = presenter.completedTrackersRecords.first {
			$0.trackerId == tracker.id && $0.date.isDayEqualTo(currentDate)
		}

		cell.isCompleted = isTrackerCompletedForCurrentDay != nil
		cell.isPinned = tracker.isPinned

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
            withReuseIdentifier: TrackersCollectionSectionHeader.reuseIdentifier,
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
        
		if cell.isCompleted {
            guard let _ = try? presenter.incomplete(tracker: tracker) else { return }
        } else {
            guard let _ = try? presenter.complete(tracker: tracker) else { return }
        }
        
		cell.dayCount = self.completedTimesCount(trackerId: tracker.id)
    }
}

private extension TrackersViewPresenterCollectionHelper {
	func completedTimesCount(trackerId: UUID) -> String {
		guard let presenter = self.presenter else {
			assertionFailure("presenter is nil")
			return ""
		}

		let times = presenter.completedTimesCount(trackerId: trackerId)
		let dayCount = R.string.localizable.stringKey(days: times)
		return dayCount
	}

	func prepareContextActions(for cell: TrackersCollectionViewCell) -> [UIAction]? {
		guard let tracker = cell.tracker else { return nil }
		let localizable = R.string.localizable
		let editActionTitle = localizable.trackersCollectionViewActionEdit()
		let deleteActionTitle = localizable.trackersCollectionViewActionDelete()

		var actions: [UIAction] = [
			UIAction(title: editActionTitle) { [weak self] _ in
				self?.presenter?.didTapEditTracker()
			},
			UIAction(title: deleteActionTitle, attributes: .destructive) { [weak self] _ in
				self?.presenter?.didTapDeleteTracker(tracker)
			}
		]

		if cell.isPinned {
			let unpinAction = self.getPinningAction(shouldPin: false, cell: cell, tracker: tracker)
			actions.insert(unpinAction, at: 0)
		} else {
			let pinAction = self.getPinningAction(shouldPin: true, cell: cell, tracker: tracker)
			actions.insert(pinAction, at: 0)
		}

		return actions
	}

	func getPinningAction(shouldPin: Bool, cell: TrackersCollectionViewCell, tracker: Tracker) -> UIAction {
		let localizable = R.string.localizable
		let pinActionTitle = shouldPin ? localizable.trackersCollectionViewActionPin() : localizable.trackersCollectionViewActionUnpin()
		let pinAction = UIAction(title: pinActionTitle) { [weak self] _ in
			cell.isPinned = shouldPin
			self?.presenter?.didTapPinTracker(shouldPin: shouldPin, tracker)
		}
		return pinAction
	}
}
