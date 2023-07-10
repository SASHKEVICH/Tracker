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
    var optionsTitles: [String]? { get }
    var selectedWeekDays: Set<WeekDay> { get }
	var selectedCategory: TrackerCategory? { get }
    func didTapTrackerScheduleCell()
	func didTapTrackerCategoryCell()
}

protocol TrackerAddingViewPresenterProtocol: AnyObject {
    var view: TrackerAddingViewControllerProtocol? { get set }
    var tableViewHelper: TrackerOptionsTableViewHelperProtocol? { get }
    var textFieldHelper: TrackerTitleTextFieldHelperProtocol? { get }
    var colorsCollectionViewHelper: ColorsCollectionViewHelperProtocol? { get }
    var emojisCollectionViewHelper: EmojisCollectionViewHelperProtocol? { get }
    func viewDidLoad()
    func didChangeTrackerTitle(_ title: String?)
    func didConfirmAddTracker()
    func didRecieveSelectedTrackerSchedule(_ weekDays: Set<WeekDay>)
	func didRecieveSelectedCategory(_ category: TrackerCategory)
}

final class TrackerAddingViewPresenter {
    weak var view: TrackerAddingViewControllerProtocol?

	var optionsTitles: [String]?

	var tableViewHelper: TrackerOptionsTableViewHelperProtocol?
	var textFieldHelper: TrackerTitleTextFieldHelperProtocol?
	var colorsCollectionViewHelper: ColorsCollectionViewHelperProtocol?
	var emojisCollectionViewHelper: EmojisCollectionViewHelperProtocol?
    
    private let trackersAddingService: TrackersAddingServiceProtocol
	private let router: TrackerAddingRouterProtocol
	private let trackerType: Tracker.TrackerType
    
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
    
    private var selectedTrackerEmoji: String? {
        didSet {
			self.checkToEnablingAddTrackerButton()
        }
    }
    
    private var selectedTrackerColor: UIColor? {
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
    
    init(
        trackersAddingService: TrackersAddingServiceProtocol,
		router: TrackerAddingRouterProtocol,
		trackerType: Tracker.TrackerType
    ) {
		self.trackersAddingService = trackersAddingService
		self.router = router
        self.trackerType = trackerType
        
        setupTableViewHelper()
        setupTextFieldHelper()
        setupColorsCollectionViewHelper()
        setupEmojisCollectionViewHelper()
    }
}

// MARK: - AddTrackerViewPresenterTableViewHelperProtocol
extension TrackerAddingViewPresenter: TrackerAddingViewPresenterTableViewHelperProtocol {
    func didTapTrackerScheduleCell() {
		self.router.navigateToScheduleScreen(selectedWeekDays: self.selectedWeekDays)
    }

	func didTapTrackerCategoryCell() {
		self.router.navigateToCategoryScreen()
	}
}

// MARK: - AddTrackerViewPresenterCollectionColorsViewHelperProtocol
extension TrackerAddingViewPresenter: TrackerAddingViewPresenterCollectionColorsViewHelperProtocol {
    func didSelect(color: UIColor) {
		self.selectedTrackerColor = color
    }
}

// MARK: - AddTrackerViewPresenterEmojisCollectionViewHelperProtocol
extension TrackerAddingViewPresenter: TrackerAddingViewPresenterEmojisCollectionViewHelperProtocol {
    func didSelect(emoji: String) {
		self.selectedTrackerEmoji = emoji
    }
}

// MARK: - Internal methods
extension TrackerAddingViewPresenter: TrackerAddingViewPresenterProtocol {
    func viewDidLoad() {
		self.setupViewController(for: trackerType)
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
			  let color = self.selectedTrackerColor,
			  let emoji = self.selectedTrackerEmoji,
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
    func setupTableViewHelper() {
        let tableViewHelper = TrackerOptionsTableViewHelper()
        tableViewHelper.presenter = self
        self.tableViewHelper = tableViewHelper
    }
    
    func setupTextFieldHelper() {
        let textFieldHelper = TrackerTitleTextFieldHelper()
        textFieldHelper.presenter = self
        self.textFieldHelper = textFieldHelper
    }
    
    func setupColorsCollectionViewHelper() {
        let colorsCollectionViewHelper = ColorsCollectionViewHelper()
        colorsCollectionViewHelper.presenter = self
        self.colorsCollectionViewHelper = colorsCollectionViewHelper
    }
    
    func setupEmojisCollectionViewHelper() {
        let emojisCollectionViewHelper = EmojisCollectionViewHelper()
        emojisCollectionViewHelper.presenter = self
        self.emojisCollectionViewHelper = emojisCollectionViewHelper
    }
    
	func setupViewController(for type: Tracker.TrackerType) {
        switch type {
        case .tracker:
            self.optionsTitles = ["Категория", "Расписание"]
			self.view?.setViewControllerTitle("Новая привычка")
        case .irregularEvent:
            self.optionsTitles = ["Категория"]
			self.view?.setViewControllerTitle("Новое нерегулярное событие")
        }
    }
}

// MARK: - Checking enabling add tracker button
private extension TrackerAddingViewPresenter {
    func checkToEnablingAddTrackerButton() {
        guard let trackerTitle = self.trackerTitle,
			  let isErrorLabelHidden = self.isErrorLabelHidden,
			  let _ = self.selectedTrackerColor,
			  let _ = self.selectedTrackerEmoji,
			  let _ = self.selectedCategory
        else { return }
    
        if !trackerTitle.isEmpty && isErrorLabelHidden && !doesItNeedToWaitSelectedWeekdays {
            view?.enableAddButton()
        } else {
            view?.disableAddButton()
        }
    }
}
