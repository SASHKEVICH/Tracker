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

	private var addingView: TrackerAddingViewProtocol
	private let router: TrackerAddingRouterProtocol
	private var viewModel: TrackerAddingViewModelProtocol

	init(
		viewModel: TrackerAddingViewModelProtocol,
		router: TrackerAddingRouterProtocol,
		view: TrackerAddingViewProtocol
	) {
		self.viewModel = viewModel
		self.router = router
		self.addingView = view
		super.init(nibName: nil, bundle: nil)

		self.configureView()
		self.bind()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		guard let view = self.addingView as? UIView else { return }
		self.view = view
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.addingView.shouldEnableConfirmButton(self.viewModel.isConfirmButtonDisabled)
	}
}

// MARK: - TrackerCategoryViewControllerDelegate
extension TrackerAddingViewController: TrackerCategoryViewControllerDelegate {
	func didRecieveCategory(_ category: TrackerCategory) {
		self.viewModel.didSelect(category: category)
	}
}

// MARK: - TrackerScheduleViewControllerDelegate
extension TrackerAddingViewController: TrackerScheduleViewControllerDelegate {
	func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>) {
		self.viewModel.didSelect(weekDays: weekDays)
		self.dismiss(animated: true)
	}
}

// MARK: - TrackerOptionsTableViewDelegate
extension TrackerAddingViewController: TrackerOptionsTableViewDelegate {
	var optionsTitles: [String] {
		self.viewModel.optionsTitles
	}

	var selectedWeekDays: [WeekDay] {
		Array(self.viewModel.selectedWeekDays)
	}

	var selectedCategory: TrackerCategory? {
		self.viewModel.selectedCategory
	}

	func didTapScheduleCell() {
		let weekDays = self.viewModel.selectedWeekDays
		self.router.navigateToScheduleScreen(selectedWeekDays: weekDays, from: self)
	}

	func didTapCategoryCell() {
		let category = self.viewModel.selectedCategory
		self.router.navigateToCategoryScreen(selectedCategory: category, from: self)
	}
}

// MARK: - TrackerEmojisCollectionViewDelegate
extension TrackerAddingViewController: TrackerEmojisCollectionViewDelegate {
	var selectedEmoji: String? {
		self.viewModel.selectedEmoji
	}

	func didSelect(emoji: String) {
		self.viewModel.didSelect(emoji: emoji)
	}
}

// MARK: - TrackerColorCollectionViewDelegate
extension TrackerAddingViewController: TrackerColorCollectionViewDelegate {
	var selectedColor: UIColor? {
		self.viewModel.selectedColor
	}

	func didSelect(color: UIColor) {
		self.viewModel.didSelect(color: color)
	}
}

private extension TrackerAddingViewController {
	func configureView() {
		self.view.backgroundColor = .Dynamic.whiteDay
		self.isModalInPresentation = true

		self.addingView.viewTitle = self.viewModel.viewControllerTitle
		self.addingView.trackerTitle = self.viewModel.trackerTitle

		self.addingView.didTapCancel = { [weak self] in
			self?.router.navigateToMainScreen()
		}

		self.addingView.didTapConfirm = { [weak self] in
			guard let self = self else { return }
			self.router.navigateToMainScreen()
			self.viewModel.didConfirmTracker()
		}

		self.addingView.didChangeTrackerTitle = { [weak self] title in
			guard let self = self else { return }
			self.viewModel.didChangeTracker(title: title)
		}

		self.addingView.didSelectTrackerTitle = { [weak self] title in
			guard let self = self else { return }
			self.viewModel.didSelect(title: title)
		}

		guard var viewModel = self.viewModel as? TrackerEditingViewModelProtocol else { return }
		self.addingView.completedTimesCount = viewModel.completedCount

		self.addingView.increaseCompletedCount = { [viewModel] in
			viewModel.increaseCompletedCount()
		}

		self.addingView.decreaseCompletedCount = { [viewModel] in
			viewModel.decreaseCompletedCount()
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

		guard var viewModel = self.viewModel as? TrackerEditingViewModelProtocol else { return }
		viewModel.onCompletedCountChanged = { [weak self] in
			self?.addingView.completedTimesCount = viewModel.completedCount
		}
	}
}
