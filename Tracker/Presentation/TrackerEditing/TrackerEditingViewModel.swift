//
//  TrackerEditingViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 16.07.2023.
//

import UIKit

protocol TrackerEditingViewModelProtocol: TrackerAddingViewModelProtocol {

}

final class TrackerEditingViewModel {
	var onOptionsTitlesChanged: (() -> Void)?
	var onTrackerTitleChanged: (() -> Void)?
	var onSelectedWeekDaysChanged: (() -> Void)?
	var onSelectedCategoryChanged: (() -> Void)?
	var onSelectedEmojiChanged: (() -> Void)?
	var onSelectedColorChanged: (() -> Void)?
	var onIsErrorHiddenChanged: (() -> Void)?
	var onIsConfirmButtonDisabledChanged: (() -> Void)?

	var trackerTitle: String? = nil {
		didSet {
			self.onTrackerTitleChanged?()
			self.checkToEnableConfirmTrackerButton()
		}
	}

	var selectedWeekDays: Set<WeekDay> = [] {
		didSet {
			self.onSelectedWeekDaysChanged?()
			self.checkToEnableConfirmTrackerButton()
		}
	}

	var selectedCategory: TrackerCategory? = nil {
		didSet {
			self.onSelectedCategoryChanged?()
			self.checkToEnableConfirmTrackerButton()
		}
	}

	var selectedEmoji: String? = nil {
		didSet {
			self.onSelectedEmojiChanged?()
			self.checkToEnableConfirmTrackerButton()
		}
	}

	var selectedColor: UIColor? = nil {
		didSet {
			self.onSelectedColorChanged?()
			self.checkToEnableConfirmTrackerButton()
		}
	}

	var isConfirmButtonDisabled: Bool = true {
		didSet {
			self.onIsConfirmButtonDisabledChanged?()
		}
	}

	var isErrorHidden: Bool = true {
		didSet {
			self.onIsErrorHiddenChanged?()
			self.checkToEnableConfirmTrackerButton()
		}
	}

	private let tracker: Tracker
	
	private let trackersAddingService: TrackersAddingServiceProtocol
	private let trackersRecordService: TrackersRecordServiceProtocol
	private let trackersCompletetingService: TrackersCompletingServiceProtocol
	private let trackersCategoryService: TrackersCategoryServiceProtocol

	init(
		trackersAddingService: TrackersAddingServiceProtocol,
		trackersRecordService: TrackersRecordServiceProtocol,
		trackersCompletingService: TrackersCompletingServiceProtocol,
		trackersCategoryService: TrackersCategoryServiceProtocol,
		tracker: Tracker
	) {
		self.trackersAddingService = trackersAddingService
		self.trackersRecordService = trackersRecordService
		self.trackersCompletetingService = trackersCompletingService
		self.trackersCategoryService = trackersCategoryService
		self.tracker = tracker

		if self.tracker.type == .irregularEvent {
			self.selectedWeekDays = Set(WeekDay.allCases)
		}

		self.configure()
	}
}

// MARK: - TrackerEditingViewModelProtocol
extension TrackerEditingViewModel: TrackerEditingViewModelProtocol {
	var optionsTitles: [String] {
		let localizable = R.string.localizable
		let categoryTitle = localizable.trackerAddingOptionTitleCategory()
		switch self.tracker.type {
		case .tracker:
			let scheduleTitle = localizable.trackerAddingOptionTitleSchedule()
			return [categoryTitle, scheduleTitle]
		case .irregularEvent:
			return [categoryTitle]
		}
	}

	var viewControllerTitle: String {
		return R.string.localizable.trackerAddingFlowEditViewControllerTitle()
	}

	func didChangeTracker(title: String) {
		self.isErrorHidden = title.count < 38
	}

	func didConfirmTracker() {
		guard let title = self.trackerTitle,
			  let color = self.selectedColor,
			  let emoji = self.selectedEmoji,
			  let category = self.selectedCategory
		else { return }

		let schedule = self.tracker.type == .irregularEvent ? Set(WeekDay.allCases) : self.selectedWeekDays

		self.trackersAddingService.addTracker(
			title: title,
			schedule: schedule,
			type: self.tracker.type,
			color: color,
			emoji: emoji,
			categoryId: category.id
		)
	}

	func didSelect(color: UIColor) {
		self.selectedColor = color
	}

	func didSelect(emoji: String) {
		self.selectedEmoji = emoji
	}

	func didSelect(category: TrackerCategory) {
		self.selectedCategory = category
	}

	func didSelect(weekDays: Set<WeekDay>) {
		self.selectedWeekDays = weekDays
	}

	func didSelect(title: String) {
		self.trackerTitle = title
	}
}

// MARK: - TrackerScheduleViewControllerDelegate
extension TrackerEditingViewModel: TrackerScheduleViewControllerDelegate {
	func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>) {
		self.selectedWeekDays = weekDays
	}
}

// MARK: - TrackerCategoryViewControllerDelegate
extension TrackerEditingViewModel: TrackerCategoryViewControllerDelegate {
	func didRecieveCategory(_ category: TrackerCategory) {
		self.selectedCategory = category
	}
}

private extension TrackerEditingViewModel {
	func configure() {
		self.trackerTitle = self.tracker.title
		self.selectedWeekDays = Set(self.tracker.schedule)
		self.selectedEmoji = self.tracker.emoji
		self.selectedColor = self.tracker.color
		self.selectedCategory = self.trackersCategoryService.category(for: self.tracker)
	}

	func checkToEnableConfirmTrackerButton() {
		guard let trackerTitle = self.trackerTitle,
			  let _ = self.selectedColor,
			  let _ = self.selectedEmoji,
			  let _ = self.selectedCategory
		else { return }

		let enablingCondition = !trackerTitle.isEmpty && self.isErrorHidden && self.selectedWeekDays.isEmpty

		guard self.isConfirmButtonDisabled != enablingCondition else { return }
		self.isConfirmButtonDisabled = enablingCondition == false
	}
}
