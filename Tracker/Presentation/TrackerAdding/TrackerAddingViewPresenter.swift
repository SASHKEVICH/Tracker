//
//  TrackerAddingViewPresenter.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.04.2023.
//

import UIKit

protocol TrackerAddingViewPresenterEmojisCollectionViewHelperProtocol: AnyObject {
    func didSelect(emoji: String)
}

protocol TrackerAddingViewPresenterCollectionColorsViewHelperProtocol: AnyObject {
    func didSelect(color: UIColor)
}

protocol TrackerAddingViewPresenterTableViewHelperProtocol: AnyObject {
    var optionsTitles: [String] { get }
    var selectedWeekDays: Set<WeekDay> { get }
	var selectedCategory: TrackerCategory? { get }
    func didTapTrackerScheduleCell()
	func didTapTrackerCategoryCell()
}

protocol TrackerAddingViewPresenterProtocol: AnyObject {
    var view: TrackerAddingViewControllerProtocol? { get set }
    var tableViewHelper: TrackerOptionsTableViewHelperProtocol { get }
    var textFieldHelper: TrackerTitleTextFieldHelperProtocol { get }
    var colorsCollectionViewHelper: ColorsCollectionViewHelperProtocol { get }
    var emojisCollectionViewHelper: EmojisCollectionViewHelperProtocol { get }
    func viewDidLoad()
    func didChangeTrackerTitle(_ title: String?)
    func didConfirmAddTracker()
	func didCancelAddTracker()
    func didRecieveSelectedTrackerSchedule(_ weekDays: Set<WeekDay>)
	func didRecieveSelectedCategory(_ category: TrackerCategory)
}

final class TrackerAddingViewPresenter {
	enum Flow {
		case add
		case edit(Tracker)
	}

	weak var view: TrackerAddingViewControllerProtocol?

	var optionsTitles: [String] = []

	lazy var tableViewHelper: TrackerOptionsTableViewHelperProtocol = {
		let helper = TrackerOptionsTableViewHelper()
		helper.presenter = self
		return helper
	}()

	lazy var textFieldHelper: TrackerTitleTextFieldHelperProtocol = {
		let helper = TrackerTitleTextFieldHelper()
		helper.presenter = self
		return helper
	}()

	lazy var colorsCollectionViewHelper: ColorsCollectionViewHelperProtocol = {
		let helper = ColorsCollectionViewHelper()
		helper.presenter = self
		return helper
	}()

	lazy var emojisCollectionViewHelper: EmojisCollectionViewHelperProtocol = {
		let helper = EmojisCollectionViewHelper()
		helper.presenter = self
		return helper
	}()

	var selectedWeekDays: Set<WeekDay> = [] {
		didSet {
			self.checkToEnablingAddTrackerButton()
		}
	}

	var selectedCategory: TrackerCategory? {
		didSet {
			self.checkToEnablingAddTrackerButton()
		}
	}
    
    private let trackersAddingService: TrackersAddingServiceProtocol
	private let router: TrackerAddingRouterProtocol
	private let trackerType: Tracker.TrackerType
	private let flow: Flow
    
    private var isErrorLabelHidden: Bool? {
        didSet {
			self.checkToEnablingAddTrackerButton()
        }
    }
    
    private var trackerTitle: String? {
        didSet {
			self.checkToEnablingAddTrackerButton()
        }
    }
    
    private var selectedEmoji: String? {
        didSet {
			self.checkToEnablingAddTrackerButton()
        }
    }
    
    private var selectedColor: UIColor? {
        didSet {
			self.checkToEnablingAddTrackerButton()
        }
    }
    
    private var doesItNeedToWaitSelectedWeekdays: Bool {
        switch trackerType {
        case .tracker:
            return selectedWeekDays.isEmpty
        case .irregularEvent:
            return false
        }
    }
    
    init(
        trackersAddingService: TrackersAddingServiceProtocol,
		router: TrackerAddingRouterProtocol,
		trackerType: Tracker.TrackerType,
		flow: Flow
    ) {
		self.trackersAddingService = trackersAddingService
		self.router = router
		self.flow = flow
        self.trackerType = trackerType
    }
}

// MARK: - AddTrackerViewPresenterTableViewHelperProtocol
extension TrackerAddingViewPresenter: TrackerAddingViewPresenterTableViewHelperProtocol {
    func didTapTrackerScheduleCell() {
		self.router.navigateToScheduleScreen(selectedWeekDays: self.selectedWeekDays)
    }

	func didTapTrackerCategoryCell() {
		self.router.navigateToCategoryScreen(selectedCategory: selectedCategory)
	}
}

// MARK: - AddTrackerViewPresenterCollectionColorsViewHelperProtocol
extension TrackerAddingViewPresenter: TrackerAddingViewPresenterCollectionColorsViewHelperProtocol {
    func didSelect(color: UIColor) {
		self.selectedColor = color
    }
}

// MARK: - AddTrackerViewPresenterEmojisCollectionViewHelperProtocol
extension TrackerAddingViewPresenter: TrackerAddingViewPresenterEmojisCollectionViewHelperProtocol {
    func didSelect(emoji: String) {
		self.selectedEmoji = emoji
    }
}

// MARK: - TrackerAddingViewPresenterProtocol
extension TrackerAddingViewPresenter: TrackerAddingViewPresenterProtocol {
    func viewDidLoad() {
		switch self.flow {
		case .add:
			self.setupViewControllerAddingFlow(for: self.trackerType)
		case .edit(let tracker):
			self.setupViewControllerEditingFlow(tracker: tracker)
		}
    }
    
    func didChangeTrackerTitle(_ title: String?) {
        let maxSymbolsCount = 38
        guard let title = title, title.count < maxSymbolsCount else {
			self.isErrorLabelHidden = self.view?.showError()
            return
        }
        
		self.isErrorLabelHidden = self.view?.hideError()
        self.trackerTitle = title
    }
    
    func didConfirmAddTracker() {
		guard let title = self.trackerTitle,
			  let color = self.selectedColor,
			  let emoji = self.selectedEmoji,
			  let category = self.selectedCategory
        else { return }
        
		let schedule = self.trackerType == .irregularEvent ? Set(WeekDay.allCases) : selectedWeekDays
        
		self.trackersAddingService.addTracker(
            title: title,
            schedule: schedule,
            type: trackerType,
            color: color,
            emoji: emoji,
			categoryId: category.id
		)
		self.router.navigateToMainScreen()
    }

	func didCancelAddTracker() {
		self.router.navigateToMainScreen()
	}
    
    func didRecieveSelectedTrackerSchedule(_ weekDays: Set<WeekDay>) {
		self.selectedWeekDays = weekDays
    }

	func didRecieveSelectedCategory(_ category: TrackerCategory) {
		self.selectedCategory = category
	}
}

// MARK: - Private methods
private extension TrackerAddingViewPresenter {
	func setupViewControllerAddingFlow(for type: Tracker.TrackerType) {
		let localizables = R.string.localizable
		let categoryTitle = localizables.trackerAddingOptionTitleCategory()
        switch type {
        case .tracker:
			let scheduleTitle = localizables.trackerAddingOptionTitleSchedule()
			self.optionsTitles = [categoryTitle, scheduleTitle]
			self.view?.setViewControllerTitle(localizables.trackerAddingTrackerViewControllerTitle())
        case .irregularEvent:
            self.optionsTitles = [categoryTitle]
			self.view?.setViewControllerTitle(localizables.trackerAddingIrregularEventViewControllerTitle())
        }
    }

	func setupViewControllerEditingFlow(tracker: Tracker) {
		let localizable = R.string.localizable
		let categoryTitle = localizable.trackerAddingOptionTitleCategory()
		switch tracker.type {
		case .tracker:
			let scheduleTitle = localizable.trackerAddingOptionTitleSchedule()
			self.optionsTitles = [categoryTitle, scheduleTitle]
		case .irregularEvent:
			self.optionsTitles = [categoryTitle]
		}
		self.view?.setViewControllerTitle(localizable.trackerAddingFlowEditViewControllerTitle())

		self.selectedWeekDays = Set(tracker.schedule)
		self.selectedColor = tracker.color
		self.selectedEmoji = tracker.emoji
	}
}

// MARK: - Checking enabling add tracker button
private extension TrackerAddingViewPresenter {
    func checkToEnablingAddTrackerButton() {
        guard let trackerTitle = self.trackerTitle,
			  let isErrorLabelHidden = self.isErrorLabelHidden,
			  let _ = self.selectedColor,
			  let _ = self.selectedEmoji,
			  let _ = self.selectedCategory
        else { return }
    
        if !trackerTitle.isEmpty && isErrorLabelHidden && !doesItNeedToWaitSelectedWeekdays {
			self.view?.enableAddButton()
        } else {
			self.view?.disableAddButton()
        }
    }
}
