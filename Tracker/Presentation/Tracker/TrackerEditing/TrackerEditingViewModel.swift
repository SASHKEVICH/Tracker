//
//  TrackerEditingViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 16.07.2023.
//

import UIKit

protocol TrackerEditingViewModelProtocol: TrackerAddingViewModelProtocol, AnyObject {
    var onCompletedCountChanged: (() -> Void)? { get set }
    var completedCount: String? { get }
    func increaseCompletedCount()
    func decreaseCompletedCount()
}

final class TrackerEditingViewModel {
    var onOptionsTitlesChanged: Binding?
    var onTrackerTitleChanged: Binding?
    var onSelectedWeekDaysChanged: Binding?
    var onSelectedCategoryChanged: Binding?
    var onSelectedEmojiChanged: Binding?
    var onSelectedColorChanged: Binding?
    var onIsErrorHiddenChanged: Binding?
    var onIsConfirmButtonDisabledChanged: Binding?
    var onCompletedCountChanged: Binding?

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

    var completedCount: String? {
        didSet {
            onCompletedCountChanged?()
        }
    }

    private var newCompletedTimes: Int = 0

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
        trackersCompletetingService = trackersCompletingService
        self.trackersCategoryService = trackersCategoryService
        self.tracker = tracker

        if self.tracker.type == .irregularEvent {
            selectedWeekDays = Set(WeekDay.allCases)
        }

        loadInfo()
    }
}

// MARK: - TrackerEditingViewModelProtocol

extension TrackerEditingViewModel: TrackerEditingViewModelProtocol {
    var optionsTitles: [String] {
        let localizable = R.string.localizable
        let categoryTitle = localizable.trackerAddingOptionTitleCategory()
        switch tracker.type {
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
        isErrorHidden = title.count < 38
    }

    func didConfirmTracker() {
        guard let title = trackerTitle,
              let color = selectedColor,
              let emoji = selectedEmoji,
              let category = selectedCategory
        else { return }

        let schedule = tracker.type == .irregularEvent ? Set(WeekDay.allCases) : selectedWeekDays

        trackersAddingService.saveEdited(
            trackerId: tracker.id,
            title: title,
            schedule: schedule,
            type: tracker.type,
            color: color,
            emoji: emoji,
            newCategoryId: category.id,
            previousCategoryId: tracker.previousCategoryId,
            isPinned: tracker.isPinned
        )
        saveCompletedTimesCount()
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

    func decreaseCompletedCount() {
        guard newCompletedTimes > 0 else { return }
        newCompletedTimes -= 1
        completedCount = R.string.localizable.stringKey(days: newCompletedTimes)
    }

    func increaseCompletedCount() {
        newCompletedTimes += 1
        completedCount = R.string.localizable.stringKey(days: newCompletedTimes)
    }
}

// MARK: - TrackerScheduleViewControllerDelegate

extension TrackerEditingViewModel: TrackerScheduleViewControllerDelegate {
    func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>) {
        selectedWeekDays = weekDays
    }
}

// MARK: - TrackerCategoryViewControllerDelegate

extension TrackerEditingViewModel: TrackerCategoryViewControllerDelegate {
    func didRecieveCategory(_ category: TrackerCategory) {
        selectedCategory = category
    }
}

private extension TrackerEditingViewModel {
    func loadInfo() {
        trackerTitle = tracker.title
        selectedWeekDays = Set(tracker.schedule)
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
        selectedCategory = trackersCategoryService.category(for: tracker)
        fetchCompletedCount()
    }

    func checkToEnableConfirmTrackerButton() {
        guard let trackerTitle = trackerTitle,
              let _ = selectedColor,
              let _ = selectedEmoji,
              let _ = selectedCategory
        else { return }

        let enablingCondition = !trackerTitle.isEmpty && isErrorHidden && !selectedWeekDays.isEmpty
        isConfirmButtonDisabled = enablingCondition == false
    }

    func fetchCompletedCount() {
        let completedCount = trackersRecordService.completedTimesCount(trackerId: tracker.id)
        self.completedCount = R.string.localizable.stringKey(days: completedCount)
    }

    func saveCompletedTimesCount() {
        guard newCompletedTimes != 0 else { return }

        let id = tracker.id
        let storedTimesCount = trackersRecordService.completedTimesCount(trackerId: id)

        if storedTimesCount < newCompletedTimes {
            let amount = newCompletedTimes - storedTimesCount
            trackersCompletetingService.addRecords(for: tracker, amount: amount)
        } else if storedTimesCount > newCompletedTimes {
            let amount = storedTimesCount - newCompletedTimes
            trackersCompletetingService.removeRecords(for: tracker, amount: amount)
        }
    }
}
