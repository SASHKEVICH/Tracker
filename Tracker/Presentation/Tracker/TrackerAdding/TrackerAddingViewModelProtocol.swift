//
//  TrackerAddingViewModelProtocol.swift
//  Tracker
//
//  Created by Александр Бекренев on 16.07.2023.
//

import UIKit

protocol TrackerAddingViewModelProtocol {
    var onOptionsTitlesChanged: Binding? { get set }
    var optionsTitles: [String] { get }

    var onTrackerTitleChanged: Binding? { get set }
    var trackerTitle: String? { get }

    var onSelectedWeekDaysChanged: Binding? { get set }
    var selectedWeekDays: Set<WeekDay> { get }

    var onSelectedCategoryChanged: Binding? { get set }
    var selectedCategory: TrackerCategory? { get }

    var onSelectedEmojiChanged: Binding? { get set }
    var selectedEmoji: String? { get }

    var onSelectedColorChanged: Binding? { get set }
    var selectedColor: UIColor? { get }

    var onIsErrorHiddenChanged: Binding? { get set }
    var isErrorHidden: Bool { get }

    var onIsConfirmButtonDisabledChanged: Binding? { get set }
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
