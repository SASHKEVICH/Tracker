import UIKit

protocol MainViewCollectionHelperCellDelegate: AnyObject {
    func didTapCompleteCellButton(_ cell: MainViewCollectionViewCell)
}

protocol MainViewCollectionHelperProtocol: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var presenter: MainViewPresetnerCollectionViewProtocol? { get set }
}

final class MainViewCollectionHelper: NSObject, MainViewCollectionHelperProtocol {
    weak var presenter: MainViewPresetnerCollectionViewProtocol?
    private let collectionViewConstants = TrackerCollectionViewConstants.trackersCollectionConfiguration
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainViewCollectionHelper {
    func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt _: IndexPath
    ) -> CGSize {
        let leftInset = self.collectionViewConstants.collectionViewInsets.left
        let rightInset = self.collectionViewConstants.collectionViewInsets.right
        let horizontalCellSpacing = self.collectionViewConstants.horizontalCellSpacing
        return CGSize(width: (collectionView.bounds.width - (leftInset + rightInset + horizontalCellSpacing)) / 2, height: 148)
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt _: Int
    ) -> CGFloat {
        self.collectionViewConstants.horizontalCellSpacing
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumLineSpacingForSectionAt _: Int
    ) -> CGFloat {
        self.collectionViewConstants.verticalCellSpacing
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        insetForSectionAt _: Int
    ) -> UIEdgeInsets {
        self.collectionViewConstants.collectionViewInsets
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        referenceSizeForHeaderInSection _: Int
    ) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 50)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point _: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else { return nil }

        let indexPath = indexPaths[0]

        guard let cell = collectionView.cellForItem(at: indexPath) as? MainViewCollectionViewCell else {
            return nil
        }

        guard let contextActions = self.prepareContextActions(for: cell) else { return nil }
        return UIContextMenuConfiguration(actionProvider: { _ in
            UIMenu(children: contextActions)
        })
    }
}

// MARK: - UICollectionViewDataSource

extension MainViewCollectionHelper {
    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let presenter = presenter else {
            assertionFailure("Presenter is nil")
            return 0
        }

        return presenter.numberOfItemsInSection(section)
    }

    func numberOfSections(in _: UICollectionView) -> Int {
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
            withReuseIdentifier: MainViewCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? MainViewCollectionViewCell,
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
            for: indexPath
        ) as? TrackersCollectionSectionHeader
        else {
            assertionFailure("Cannot dequeue header view")
            return UICollectionReusableView()
        }

        view.headerText = self.presenter?.categoryTitle(at: indexPath)
        return view
    }
}

// MARK: - Complete cell button handler

extension MainViewCollectionHelper: MainViewCollectionHelperCellDelegate {
    func didTapCompleteCellButton(_ cell: MainViewCollectionViewCell) {
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

private extension MainViewCollectionHelper {
    func completedTimesCount(trackerId: UUID) -> String {
        guard let presenter = self.presenter else {
            assertionFailure("presenter is nil")
            return ""
        }

        let times = presenter.completedTimesCount(trackerId: trackerId)
        let dayCount = R.string.localizable.stringKey(days: times)
        return dayCount
    }

    func prepareContextActions(for cell: MainViewCollectionViewCell) -> [UIAction]? {
        guard let tracker = cell.tracker else { return nil }
        let localizable = R.string.localizable
        let editActionTitle = localizable.trackersCollectionViewActionEdit()
        let deleteActionTitle = localizable.trackersCollectionViewActionDelete()

        var actions: [UIAction] = [
            UIAction(title: editActionTitle) { [weak self] _ in
                self?.presenter?.didTapEditTracker(tracker)
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

    func getPinningAction(shouldPin: Bool, cell: MainViewCollectionViewCell, tracker: OldTrackerEntity) -> UIAction {
        let localizable = R.string.localizable
        let pinActionTitle = shouldPin
            ? localizable.trackersCollectionViewActionPin()
            : localizable.trackersCollectionViewActionUnpin()
        let pinAction = UIAction(title: pinActionTitle) { [weak self] _ in
            cell.isPinned = shouldPin
            self?.presenter?.didTapPinTracker(shouldPin: shouldPin, tracker)
        }
        return pinAction
    }
}
