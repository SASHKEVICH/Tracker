//
//  TrackerAddingViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 16.07.2023.
//

import UIKit

typealias Binding = () -> Void

final class TrackerAddingViewModel {
    var onIsConfirmButtonDisabledChanged: Binding?
    var onIsErrorHiddenChanged: Binding?
    var onOptionsTitlesChanged: Binding?
    var onTrackerTitleChanged: Binding?
    var onSelectedWeekDaysChanged: Binding?
    var onSelectedCategoryChanged: Binding?
    var onSelectedEmojiChanged: Binding?
    var onSelectedColorChanged: Binding?

    let optionsTitles: [String]
    let viewControllerTitle: String

    var trackerTitle: String? {
        didSet {
            onTrackerTitleChanged?()
            checkToEnableConfirmTrackerButton()
        }
    }

    var selectedWeekDays: Set<WeekDay> = [] {
        didSet {
            onSelectedWeekDaysChanged?()
            checkToEnableConfirmTrackerButton()
        }
    }

    var selectedCategory: TrackerCategory? {
        didSet {
            onSelectedCategoryChanged?()
            checkToEnableConfirmTrackerButton()
        }
    }

    var selectedEmoji: String? {
        didSet {
            onSelectedEmojiChanged?()
            checkToEnableConfirmTrackerButton()
        }
    }

    var selectedColor: UIColor? {
        didSet {
            onSelectedColorChanged?()
            checkToEnableConfirmTrackerButton()
        }
    }

    var isConfirmButtonDisabled: Bool = true {
        didSet {
            onIsConfirmButtonDisabledChanged?()
        }
    }

    var isErrorHidden: Bool = true {
        didSet {
            onIsErrorHiddenChanged?()
            checkToEnableConfirmTrackerButton()
        }
    }

    private let trackersAddingService: TrackersAddingServiceProtocol
    private let trackerType: Tracker.TrackerType

    init(
        trackersAddingService: TrackersAddingServiceProtocol,
        trackerType: Tracker.TrackerType,
        optionTitles: [String],
        viewControllerTitle: String
    ) {
        self.trackersAddingService = trackersAddingService
        self.trackerType = trackerType
        optionsTitles = optionTitles
        self.viewControllerTitle = viewControllerTitle

        if self.trackerType == .irregularEvent {
            selectedWeekDays = Set(WeekDay.allCases)
        }
    }
}

// MARK: - TrackerAddingViewModelProtocol

extension TrackerAddingViewModel: TrackerAddingViewModelProtocol {
    func didChangeTracker(title: String) {
        isErrorHidden = title.count < 38
    }

    func didConfirmTracker() {
        guard let title = trackerTitle,
              let color = selectedColor,
              let emoji = selectedEmoji,
              let category = selectedCategory
        else { return }

        let schedule = trackerType == .irregularEvent ? Set(WeekDay.allCases) : selectedWeekDays

        trackersAddingService.addTracker(
            title: title,
            schedule: schedule,
            type: trackerType,
            color: color,
            emoji: emoji,
            categoryId: category.id
        )
    }

    func didSelect(color: UIColor) {
        selectedColor = color
    }

    func didSelect(emoji: String) {
        selectedEmoji = emoji
    }

    func didSelect(category: TrackerCategory) {
        selectedCategory = category
    }

    func didSelect(weekDays: Set<WeekDay>) {
        selectedWeekDays = weekDays
    }

    func didSelect(title: String) {
        trackerTitle = title
    }
}

// MARK: - TrackerScheduleViewControllerDelegate

extension TrackerAddingViewModel: TrackerScheduleViewControllerDelegate {
    func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>) {
        selectedWeekDays = weekDays
    }
}

// MARK: - TrackerCategoryViewControllerDelegate

extension TrackerAddingViewModel: TrackerCategoryViewControllerDelegate {
    func didRecieveCategory(_ category: TrackerCategory) {
        selectedCategory = category
    }
}

private extension TrackerAddingViewModel {
    func checkToEnableConfirmTrackerButton() {
        guard let trackerTitle = trackerTitle,
              let _ = selectedColor,
              let _ = selectedEmoji,
              let _ = selectedCategory
        else { return }

        let enablingCondition = !trackerTitle.isEmpty && isErrorHidden && !selectedWeekDays.isEmpty
        isConfirmButtonDisabled = enablingCondition == false
    }
}
