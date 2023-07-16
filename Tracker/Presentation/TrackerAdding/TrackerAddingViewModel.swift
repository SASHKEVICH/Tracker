//
//  TrackerAddingViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 16.07.2023.
//

import UIKit

protocol TrackerAddingViewModelProtocol {
	var onOptionsTitlesChanged: (() -> Void)? { get set }
	var optionsTitles: [String] { get }

	var onTrackerTitleChanged: (() -> Void)? { get set }
	var trackerTitle: String? { get }

	var onSelectedWeekDaysChanged: (() -> Void)? { get set }
	var selectedWeekDays: Set<WeekDay> { get }

	var onSelectedCategoryChanged: (() -> Void)? { get set }
	var selectedCategory: TrackerCategory? { get }

	var onSelectedEmojiChanged: (() -> Void)? { get set }
	var selectedEmoji: String? { get }

	var onSelectedColorChanged: (() -> Void)? { get set }
	var selectedColor: UIColor? { get }

	var onIsErrorHiddenChanged: (() -> Void)? { get set }
	var isErrorHidden: Bool { get }

	var onIsApplyButtonDisabledChanged: (() -> Void)? { get set }
	var isApplyButtonDisabled: Bool { get }

	var viewControllerTitle: String { get }

	func didConfirmTracker()
	func didSelect(color: UIColor)
	func didSelect(emoji: String)
}

final class TrackerAddingViewModel {
	var onIsApplyButtonDisabledChanged: (() -> Void)?
	var onIsErrorHiddenChanged: (() -> Void)?
	var onOptionsTitlesChanged: (() -> Void)?
	var onTrackerTitleChanged: (() -> Void)?
	var onSelectedWeekDaysChanged: (() -> Void)?
	var onSelectedCategoryChanged: (() -> Void)?
	var onSelectedEmojiChanged: (() -> Void)?
	var onSelectedColorChanged: (() -> Void)?

	var trackerTitle: String? = nil {
		didSet {
			self.onTrackerTitleChanged?()
		}
	}

	var selectedWeekDays: Set<WeekDay> = [] {
		didSet {
			self.onSelectedWeekDaysChanged?()
		}
	}

	var selectedCategory: TrackerCategory? = nil {
		didSet {
			self.onSelectedCategoryChanged?()
		}
	}

	var selectedEmoji: String? = nil {
		didSet {
			self.onSelectedEmojiChanged?()
		}
	}

	var selectedColor: UIColor? = nil {
		didSet {
			self.onSelectedColorChanged?()
		}
	}

	var isApplyButtonDisabled: Bool = true {
		didSet {
			self.onIsApplyButtonDisabledChanged?()
		}
	}

	var isErrorHidden: Bool = true {
		didSet {
			self.onIsErrorHiddenChanged?()
		}
	}

	private let trackersAddingService: TrackersAddingServiceProtocol
	private let trackerType: Tracker.TrackerType

	init(
		trackersAddingService: TrackersAddingServiceProtocol,
		trackerType: Tracker.TrackerType
	) {
		self.trackersAddingService = trackersAddingService
		self.trackerType = trackerType
	}
}

// MARK: - TrackerAddingViewModelProtocol
extension TrackerAddingViewModel: TrackerAddingViewModelProtocol {
	var optionsTitles: [String] {
		let localizable = R.string.localizable
		let categoryTitle = localizable.trackerAddingOptionTitleCategory()
		switch self.trackerType {
		case .tracker:
			let scheduleTitle = localizable.trackerAddingOptionTitleSchedule()
			return [categoryTitle, scheduleTitle]
		case .irregularEvent:
			return [categoryTitle]
		}
	}

	var viewControllerTitle: String {
		let localizable = R.string.localizable
		switch self.trackerType {
		case .tracker:
			return localizable.trackerAddingTrackerViewControllerTitle()
		case .irregularEvent:
			return localizable.trackerAddingIrregularEventViewControllerTitle()
		}
	}

	func didConfirmTracker() {
		guard let title = self.trackerTitle,
			  let color = self.selectedColor,
			  let emoji = self.selectedEmoji,
			  let category = self.selectedCategory
		else { return }

		let schedule = self.trackerType == .irregularEvent ? Set(WeekDay.allCases) : self.selectedWeekDays

		self.trackersAddingService.addTracker(
			title: title,
			schedule: schedule,
			type: self.trackerType,
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
}

// MARK: - TrackerScheduleViewControllerDelegate
extension TrackerAddingViewModel: TrackerScheduleViewControllerDelegate {
	func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>) {
		self.selectedWeekDays = weekDays
	}
}

// MARK: - TrackerCategoryViewControllerDelegate
extension TrackerAddingViewModel: TrackerCategoryViewControllerDelegate {
	func didRecieveCategory(_ category: TrackerCategory) {
		self.selectedCategory = category
	}
}

private extension TrackerAddingViewModel {
	
}
