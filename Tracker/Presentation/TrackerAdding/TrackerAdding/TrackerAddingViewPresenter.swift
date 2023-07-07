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
}

final class TrackerAddingViewPresenter: TrackerAddingViewPresenterProtocol {
    weak var view: TrackerAddingViewControllerProtocol?

	var optionsTitles: [String]?

	var tableViewHelper: TrackerOptionsTableViewHelperProtocol?
	var textFieldHelper: TrackerTitleTextFieldHelperProtocol?
	var colorsCollectionViewHelper: ColorsCollectionViewHelperProtocol?
	var emojisCollectionViewHelper: EmojisCollectionViewHelperProtocol?
    
    private let trackersService: TrackersServiceAddingProtocol
	private let trackerType: Tracker.TrackerType
    
    private var isErrorLabelHidden: Bool? {
        didSet {
            checkToEnablingAddTrackerButton()
        }
    }
    
    private var trackerTitle: String? {
        didSet {
            checkToEnablingAddTrackerButton()
        }
    }
    
    private var selectedTrackerEmoji: String? {
        didSet {
            checkToEnablingAddTrackerButton()
        }
    }
    
    private var selectedTrackerColor: UIColor? {
        didSet {
            checkToEnablingAddTrackerButton()
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
            checkToEnablingAddTrackerButton()
        }
    }
    
    init(
        trackersService: TrackersServiceAddingProtocol,
		trackerType: Tracker.TrackerType
    ) {
        self.trackerType = trackerType
        self.trackersService = trackersService
        
        setupTableViewHelper()
        setupTextFieldHelper()
        setupColorsCollectionViewHelper()
        setupEmojisCollectionViewHelper()
    }
}

// MARK: - AddTrackerViewPresenterTableViewHelperProtocol
extension TrackerAddingViewPresenter: TrackerAddingViewPresenterTableViewHelperProtocol {
    func didTapTrackerScheduleCell() {
        let vc = TrackerScheduleViewController()
        vc.delegate = view
        view?.trackerScheduleViewController = vc
        
        let presenter = TrackerSchedulePresenter()
        vc.presenter = presenter
        presenter.view = vc
        
        presenter.selectedWeekDays = selectedWeekDays

		view?.present(view: vc)
    }

	func didTapTrackerCategoryCell() {
		let viewModel = TrackerCategoryViewModel()
		let helper = TrackerCategoryTableViewHelper()

		let vc = TrackerCategoryViewController(
			viewModel: viewModel,
			helper: helper
		)

		view?.present(view: vc)
	}
}

// MARK: - AddTrackerViewPresenterCollectionColorsViewHelperProtocol
extension TrackerAddingViewPresenter: TrackerAddingViewPresenterCollectionColorsViewHelperProtocol {
    func didSelect(color: UIColor) {
        selectedTrackerColor = color
    }
}

// MARK: - AddTrackerViewPresenterEmojisCollectionViewHelperProtocol
extension TrackerAddingViewPresenter: TrackerAddingViewPresenterEmojisCollectionViewHelperProtocol {
    func didSelect(emoji: String) {
        selectedTrackerEmoji = emoji
    }
}

// MARK: - Internal methods
extension TrackerAddingViewPresenter {
    func viewDidLoad() {
        setupViewController(for: trackerType)
    }
    
    func didChangeTrackerTitle(_ title: String?) {
        let maxSymbolsCount = 38
        guard let title = title, title.count < maxSymbolsCount else {
            isErrorLabelHidden = view?.showError()
            return
        }
        
        isErrorLabelHidden = view?.hideError()
        self.trackerTitle = title
    }
    
    func didConfirmAddTracker() {
        guard
            let title = trackerTitle,
            let color = selectedTrackerColor,
            let emoji = selectedTrackerEmoji
        else { return }
        
		let schedule = self.trackerType == .irregularEvent ? Set(WeekDay.allCases) : selectedWeekDays
        
        trackersService.addTracker(
            title: title,
            schedule: schedule,
            type: trackerType,
            color: color,
            emoji: emoji)
    }
    
    func didRecieveSelectedTrackerSchedule(_ weekDays: Set<WeekDay>) {
        selectedWeekDays = weekDays
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
            view?.setViewControllerTitle("Новая привычка")
        case .irregularEvent:
            self.optionsTitles = ["Категория"]
            view?.setViewControllerTitle("Новое нерегулярное событие")
        }
    }
}

// MARK: - Checking enabling add tracker button
private extension TrackerAddingViewPresenter {
    func checkToEnablingAddTrackerButton() {
        guard
            let trackerTitle = trackerTitle,
            let isErrorLabelHidden = isErrorLabelHidden,
            let _ = selectedTrackerColor,
            let _ = selectedTrackerEmoji
        else { return }
    
        if !trackerTitle.isEmpty && isErrorLabelHidden && !doesItNeedToWaitSelectedWeekdays {
            view?.enableAddButton()
        } else {
            view?.disableAddButton()
        }
    }
}
