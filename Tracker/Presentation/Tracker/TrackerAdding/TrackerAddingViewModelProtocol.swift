//
//  TrackerAddingViewModelProtocol.swift
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

	var onIsConfirmButtonDisabledChanged: (() -> Void)? { get set }
	var isConfirmButtonDisabled: Bool { get }

	var viewControllerTitle: String { get }

	func didChangeTracker(title: String)

	func didConfirmTracker()
	func didSelect(color: UIColor)
	func didSelect(emoji: String)
	func didSelect(category: TrackerCategory)
	func didSelect(weekDays: Set<WeekDay>)
	func didSelect(title: String)
}
