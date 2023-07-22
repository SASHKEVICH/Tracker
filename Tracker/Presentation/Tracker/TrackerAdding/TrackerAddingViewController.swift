//
//  TrackerAddingViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.04.2023.
//

import UIKit

protocol TrackerAddingViewControllerProtocol: AnyObject {
    var emptyTap: (() -> Void)? { get set }
}

final class TrackerAddingViewController: UIViewController {
    var emptyTap: (() -> Void)?

    private let router: TrackerAddingRouterProtocol
    private var addingView: TrackerAddingViewProtocol
    private var viewModel: TrackerAddingViewModelProtocol

    init(
        router: TrackerAddingRouterProtocol,
        view: TrackerAddingViewProtocol,
        viewModel: TrackerAddingViewModelProtocol
    ) {
        self.viewModel = viewModel
        self.router = router
        addingView = view
        super.init(nibName: nil, bundle: nil)

        configureView()
        bind()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        guard let view = addingView as? UIView else { return }
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addingView.shouldEnableConfirmButton(viewModel.isConfirmButtonDisabled)
    }
}

// MARK: - TrackerCategoryViewControllerDelegate

extension TrackerAddingViewController: TrackerCategoryViewControllerDelegate {
    func didRecieveCategory(_ category: TrackerCategory) {
        viewModel.didSelect(category: category)
    }
}

// MARK: - TrackerScheduleViewControllerDelegate

extension TrackerAddingViewController: TrackerScheduleViewControllerDelegate {
    func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>) {
        viewModel.didSelect(weekDays: weekDays)
        dismiss(animated: true)
    }
}

// MARK: - TrackerOptionsTableViewDelegate

extension TrackerAddingViewController: TrackerOptionsTableViewDelegate {
    var optionsTitles: [String] {
        viewModel.optionsTitles
    }

    var selectedWeekDays: [WeekDay] {
        Array(viewModel.selectedWeekDays)
    }

    var selectedCategory: TrackerCategory? {
        viewModel.selectedCategory
    }

    func didTapScheduleCell() {
        let weekDays = viewModel.selectedWeekDays
        router.navigateToScheduleScreen(selectedWeekDays: weekDays, from: self)
    }

    func didTapCategoryCell() {
        let category = viewModel.selectedCategory
        router.navigateToCategoryScreen(selectedCategory: category, from: self)
    }
}

// MARK: - TrackerEmojisCollectionViewDelegate

extension TrackerAddingViewController: TrackerEmojisCollectionViewDelegate {
    var selectedEmoji: String? {
        viewModel.selectedEmoji
    }

    func didSelect(emoji: String) {
        viewModel.didSelect(emoji: emoji)
    }
}

// MARK: - TrackerColorCollectionViewDelegate

extension TrackerAddingViewController: TrackerColorCollectionViewDelegate {
    var selectedColor: UIColor? {
        viewModel.selectedColor
    }

    func didSelect(color: UIColor) {
        viewModel.didSelect(color: color)
    }
}

private extension TrackerAddingViewController {
    func configureView() {
        view.backgroundColor = .Dynamic.whiteDay
        isModalInPresentation = true

        addingView.viewTitle = self.viewModel.viewControllerTitle
        addingView.trackerTitle = self.viewModel.trackerTitle

        addingView.didTapCancel = { [weak self] in
            self?.router.navigateToMainScreen()
        }

        addingView.didTapConfirm = { [weak self] in
            guard let self = self else { return }
            self.router.navigateToMainScreen()
            self.viewModel.didConfirmTracker()
        }

        addingView.didChangeTrackerTitle = { [weak self] title in
            guard let self = self else { return }
            self.viewModel.didChangeTracker(title: title)
        }

        addingView.didSelectTrackerTitle = { [weak self] title in
            guard let self = self else { return }
            self.viewModel.didSelect(title: title)
        }

        guard let viewModel = viewModel as? TrackerEditingViewModelProtocol else { return }
        addingView.completedTimesCount = viewModel.completedCount

        addingView.increaseCompletedCount = { [weak viewModel] in
            viewModel?.increaseCompletedCount()
        }

        addingView.decreaseCompletedCount = { [weak viewModel] in
            viewModel?.decreaseCompletedCount()
        }
    }

    func bind() {
        self.viewModel.onSelectedCategoryChanged = { [weak self] in
            self?.addingView.reloadOptionsTable()
        }

        self.viewModel.onSelectedWeekDaysChanged = { [weak self] in
            self?.addingView.reloadOptionsTable()
        }

        self.viewModel.onIsConfirmButtonDisabledChanged = { [weak self] in
            guard let self = self else { return }
            self.addingView.shouldEnableConfirmButton(self.viewModel.isConfirmButtonDisabled)
        }

        self.viewModel.onIsErrorHiddenChanged = { [weak self] in
            guard let self = self else { return }
            self.addingView.shouldHideErrorLabelWithAnimation(self.viewModel.isErrorHidden)
        }

        guard var viewModel = viewModel as? TrackerEditingViewModelProtocol else { return }
        viewModel.onCompletedCountChanged = { [weak self, weak viewModel] in
            self?.addingView.completedTimesCount = viewModel?.completedCount
        }
    }
}
