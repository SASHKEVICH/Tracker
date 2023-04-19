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
    func viewDidLoad(type: TrackerType)
    func didChangeTrackerTitleTextField(text: String?)
    func didConfirmAddTracker()
    func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>)
}

final class AddTrackerViewPresenter: AddTrackerViewPresenterProtocol {
    static let didAddTrackerNotificationName = Notification.Name(rawValue: "NewTrackerAdded")
    
    weak var view: AddTrackerViewControllerProtocol?
    
    private var trackersService: TrackersServiceAddingProtocol = TrackersService.shared
    
    var optionsTitles: [String]?
    
    var tableViewHelper: TrackerOptionsTableViewHelperProtocol?
    var textFieldHelper: TrackerTitleTextFieldHelperProtocol?
    
    var trackerTitle: String?
    var selectedWeekDays: Set<WeekDay>?

    init() {
        setupTableViewHelper()
        setupTextFieldHelper()
    }
}

// MARK: - Internal methods
extension AddTrackerViewPresenter {
    func viewDidLoad(type: TrackerType) {
        setupOptionsTitles(type: type)
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
    
    func didChangeTrackerTitleTextField(text: String?) {
        let maxSymbolsCount = 38
        guard let text = text, text.count < maxSymbolsCount else {
            view?.showError()
            return
        }
        
        view?.hideError()
        self.trackerTitle = text
    }
    
    func didConfirmAddTracker() {
        guard let title = trackerTitle, let schedule = selectedWeekDays else { return }
        trackersService.addTracker(title: title, schedule: schedule)
        postAddingTrackerNotification()
    }
    
    func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>) {
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
    
    func setupOptionsTitles(type: TrackerType) {
        switch type {
        case .tracker:
            self.optionsTitles = ["Категория", "Расписание"]
        case .irregularEvent:
            self.optionsTitles = ["Категория"]
        }
    }
    
    func postAddingTrackerNotification() {
        NotificationCenter.default
            .post(name: AddTrackerViewPresenter.didAddTrackerNotificationName,
                  object: self)
    }
}
