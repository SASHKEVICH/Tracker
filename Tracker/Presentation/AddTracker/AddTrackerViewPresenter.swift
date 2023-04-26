//
//  AddTrackerViewPresenter.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.04.2023.
//

import Foundation

protocol AddTrackerViewPresenterTableViewHelperProtocol: AnyObject {
    var optionsTitles: [String]? { get }
    var selectedWeekDays: Set<WeekDay>? { get }
    func didTapTrackerScheduleCell()
}

protocol AddTrackerViewPresenterProtocol: AnyObject, AddTrackerViewPresenterTableViewHelperProtocol {
    var view: AddTrackerViewControllerProtocol? { get set }
    var trackerTitle: String? { get set }
    var tableViewHelper: TrackerOptionsTableViewHelperProtocol? { get }
    var textFieldHelper: TrackerTitleTextFieldHelperProtocol? { get }
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
    
    private var isErrorLabelHidden: Bool? {
        didSet {
            checkToEnablingAddTrackerButton()
        }
    }
    
    var trackerTitle: String? {
        didSet {
            checkToEnablingAddTrackerButton()
        }
    }
    
    var selectedWeekDays: Set<WeekDay>? {
        didSet {
            checkToEnablingAddTrackerButton()
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
    }
}

// MARK: - Internal methods
extension AddTrackerViewPresenter {
    func viewDidLoad() {
        setupViewController(for: trackerType)
    }
    
    func didTapTrackerScheduleCell() {
        let vc = TrackerScheduleViewController()
        vc.delegate = view
        view?.trackerScheduleViewController = vc
        
        let presenter = TrackerSchedulePresenter()
        vc.presenter = presenter
        presenter.view = vc
        
        view?.didTapTrackerScheduleCell(vc)
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
        guard let title = trackerTitle, let schedule = selectedWeekDays else { return }
        trackersService.addTracker(title: title, schedule: schedule, type: trackerType)
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
    
    func checkToEnablingAddTrackerButton() {
        guard let trackerTitle = trackerTitle, let isErrorLabelHidden = isErrorLabelHidden else { return }
        if !trackerTitle.isEmpty && isErrorLabelHidden && selectedWeekDays != nil {
            view?.enableAddButton()
        } else {
            view?.disableAddButton()
        }
    }
    
    func postAddingTrackerNotification() {
        NotificationCenter.default
            .post(name: AddTrackerViewPresenter.didAddTrackerNotificationName,
                  object: self)
    }
}
