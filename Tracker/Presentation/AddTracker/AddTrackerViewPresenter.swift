//
//  AddTrackerViewPresenter.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.04.2023.
//

import UIKit

protocol AddTrackerViewPresenterEmojisCollectionViewHelperProtocol: AnyObject {
    func didSelect(emoji: String)
}

protocol AddTrackerViewPresenterCollectionColorsViewHelperProtocol: AnyObject {
    func didSelect(color: UIColor)
}

protocol AddTrackerViewPresenterTableViewHelperProtocol: AnyObject {
    var optionsTitles: [String]? { get }
    var selectedWeekDays: Set<WeekDay>? { get }
    func didTapTrackerScheduleCell()
}

protocol AddTrackerViewPresenterProtocol: AnyObject {
    var view: AddTrackerViewControllerProtocol? { get set }
    var tableViewHelper: TrackerOptionsTableViewHelperProtocol? { get }
    var textFieldHelper: TrackerTitleTextFieldHelperProtocol? { get }
    var colorsCollectionViewHelper: ColorsCollectionViewHelperProtocol? { get }
    var emojisCollectionViewHelper: EmojisCollectionViewHelperProtocol? { get }
    func viewDidLoad()
    func didChangeTrackerTitle(_ title: String?)
    func didConfirmAddTracker()
    func didRecieveSelectedTrackerSchedule(_ weekDays: Set<WeekDay>)
}

final class AddTrackerViewPresenter: AddTrackerViewPresenterProtocol {
    static let didAddTrackerNotificationName = Notification.Name(rawValue: "NewTrackerAdded")
    
    weak var view: AddTrackerViewControllerProtocol?
    
    private let trackersService: TrackersServiceAddingProtocol
    private let trackerType: TrackerType
    
    var optionsTitles: [String]?
    
    var tableViewHelper: TrackerOptionsTableViewHelperProtocol?
    var textFieldHelper: TrackerTitleTextFieldHelperProtocol?
    var colorsCollectionViewHelper: ColorsCollectionViewHelperProtocol?
    var emojisCollectionViewHelper: EmojisCollectionViewHelperProtocol?
    
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
    
    var selectedWeekDays: Set<WeekDay>? {
        didSet {
            checkToEnablingAddTrackerButton()
        }
    }
    
    private var selectedTrackerEmoji: String?
    private var selectedTrackerColor: UIColor?
    
    private var doesItNeedToWaitSelectedWeekdays: Bool {
        switch trackerType {
        case .tracker:
            return selectedWeekDays == nil
        case .irregularEvent:
            return false
        }
    }
    
    init(
        trackersService: TrackersServiceAddingProtocol,
        trackerType: TrackerType
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
extension AddTrackerViewPresenter: AddTrackerViewPresenterTableViewHelperProtocol {
    func didTapTrackerScheduleCell() {
        let vc = TrackerScheduleViewController()
        vc.delegate = view
        view?.trackerScheduleViewController = vc
        
        let presenter = TrackerSchedulePresenter()
        vc.presenter = presenter
        presenter.view = vc
        
        view?.didTapTrackerScheduleCell(vc)
    }
}

// MARK: - AddTrackerViewPresenterCollectionColorsViewHelperProtocol
extension AddTrackerViewPresenter: AddTrackerViewPresenterCollectionColorsViewHelperProtocol {
    func didSelect(color: UIColor) {
        selectedTrackerColor = color
    }
}

// MARK: - AddTrackerViewPresenterEmojisCollectionViewHelperProtocol
extension AddTrackerViewPresenter: AddTrackerViewPresenterEmojisCollectionViewHelperProtocol {
    func didSelect(emoji: String) {
        selectedTrackerEmoji = emoji
    }
}

// MARK: - Internal methods
extension AddTrackerViewPresenter {
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
            let schedule = selectedWeekDays,
            let color = selectedTrackerColor,
            let emoji = selectedTrackerEmoji
        else { return }
        
        trackersService.addTracker(
            title: title,
            schedule: schedule,
            type: trackerType,
            color: color,
            emoji: emoji)
        postAddingTrackerNotification()
    }
    
    func didRecieveSelectedTrackerSchedule(_ weekDays: Set<WeekDay>) {
        selectedWeekDays = weekDays
    }
}

// MARK: - Private methods
private extension AddTrackerViewPresenter {
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
    
    func setupViewController(for type: TrackerType) {
        switch type {
        case .tracker:
            self.optionsTitles = ["Категория", "Расписание"]
            view?.setViewControllerTitle("Новая привычка")
        case .irregularEvent:
            self.optionsTitles = ["Категория"]
            view?.setViewControllerTitle("Новое нерегулярное событие")
        }
    }
    
    func postAddingTrackerNotification() {
        NotificationCenter.default
            .post(name: AddTrackerViewPresenter.didAddTrackerNotificationName,
                  object: self)
    }
}

// MARK: - Checking enabling add tracker button
private extension AddTrackerViewPresenter {
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
