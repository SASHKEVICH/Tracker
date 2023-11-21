import UIKit

protocol EditingViewModelProtocol: AddingViewModelProtocol, AnyObject {
    var onCompletedCountChanged: (() -> Void)? { get set }
    var completedCount: String? { get }
    func increaseCompletedCount()
    func decreaseCompletedCount()
}

final class EditingViewModel {
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

    var selectedCategory: TrackerCategory? {
        didSet {
            self.onSelectedCategoryChanged?()
            self.checkToEnableConfirmTrackerButton()
        }
    }

    var selectedEmoji: String? {
        didSet {
            self.onSelectedEmojiChanged?()
            self.checkToEnableConfirmTrackerButton()
        }
    }

    var selectedColor: UIColor? {
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

    var completedCount: String? {
        didSet {
            self.onCompletedCountChanged?()
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
        self.trackersCompletetingService = trackersCompletingService
        self.trackersCategoryService = trackersCategoryService
        self.tracker = tracker

        if self.tracker.type == .irregularEvent {
            self.selectedWeekDays = Set(WeekDay.allCases)
        }

        self.loadInfo()
    }
}

// MARK: - EditingViewModelProtocol

extension EditingViewModel: EditingViewModelProtocol {
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

        self.trackersAddingService.saveEdited(
            trackerId: self.tracker.id,
            title: title,
            schedule: schedule,
            type: self.tracker.type,
            color: color,
            emoji: emoji,
            newCategoryId: category.id,
            previousCategoryId: self.tracker.previousCategoryId,
            isPinned: self.tracker.isPinned
        )
        self.saveCompletedTimesCount()
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

    func decreaseCompletedCount() {
        guard self.newCompletedTimes > 0 else { return }
        self.newCompletedTimes -= 1
        self.completedCount = R.string.localizable.stringKey(days: newCompletedTimes)
    }

    func increaseCompletedCount() {
        self.newCompletedTimes += 1
        self.completedCount = R.string.localizable.stringKey(days: newCompletedTimes)
    }
}

// MARK: - TrackerScheduleViewControllerDelegate

extension EditingViewModel: SelectingScheduleViewControllerDelegate {
    func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>) {
        self.selectedWeekDays = weekDays
    }
}

// MARK: - CategoryViewControllerDelegate

extension EditingViewModel: CategoryViewControllerDelegate {
    func didRecieveCategory(_ category: TrackerCategory) {
        self.selectedCategory = category
    }
}

private extension EditingViewModel {
    func loadInfo() {
        self.trackerTitle = self.tracker.title
        self.selectedWeekDays = Set(self.tracker.schedule)
        self.selectedEmoji = self.tracker.emoji
        self.selectedColor = self.tracker.color
        self.selectedCategory = self.trackersCategoryService.category(for: self.tracker)
        self.fetchCompletedCount()
    }

    func checkToEnableConfirmTrackerButton() {
        guard let trackerTitle = self.trackerTitle,
              self.selectedColor != nil,
              self.selectedEmoji != nil,
              self.selectedCategory != nil
        else { return }

        let enablingCondition = !trackerTitle.isEmpty && self.isErrorHidden && !self.selectedWeekDays.isEmpty
        self.isConfirmButtonDisabled = enablingCondition == false
    }

    func fetchCompletedCount() {
        let completedCount = self.trackersRecordService.completedTimesCount(trackerId: self.tracker.id)
        self.completedCount = R.string.localizable.stringKey(days: completedCount)
    }

    func saveCompletedTimesCount() {
        guard self.newCompletedTimes != 0 else { return }

        let id = self.tracker.id
        let storedTimesCount = self.trackersRecordService.completedTimesCount(trackerId: id)

        if storedTimesCount < self.newCompletedTimes {
            let amount = self.newCompletedTimes - storedTimesCount
            self.trackersCompletetingService.addRecords(for: self.tracker, amount: amount)
        } else if storedTimesCount > self.newCompletedTimes {
            let amount = storedTimesCount - self.newCompletedTimes
            self.trackersCompletetingService.removeRecords(for: self.tracker, amount: amount)
        }
    }
}
