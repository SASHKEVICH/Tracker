//
//  AddTrackerViewPresenter.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.04.2023.
//

import Foundation

protocol AddTrackerViewPresenterTableViewHelperProtocol: AnyObject {
    var optionsTitles: [String]? { get }
    func didTapSetTrackerScheduleButton()
}

protocol AddTrackerViewPresenterProtocol: AnyObject, AddTrackerViewPresenterTableViewHelperProtocol {
    var view: AddTrackerViewControllerProtocol? { get set }
    var tableViewHelper: TrackerOptionsTableViewHelperProtocol? { get }
    var textFieldHelper: TrackerTitleTextFieldHelperProtocol? { get }
    func viewDidLoad(type: TrackerType)
    func didChangeTrackerTitleTextField(text: String?)
}

final class AddTrackerViewPresenter: AddTrackerViewPresenterProtocol {
    weak var view: AddTrackerViewControllerProtocol?
    
    var optionsTitles: [String]?
    
    var tableViewHelper: TrackerOptionsTableViewHelperProtocol?
    var textFieldHelper: TrackerTitleTextFieldHelperProtocol?
    
    var trackerTitle: String?
    
    func viewDidLoad(type: TrackerType) {
        setupOptionsTitles(type: type)
    }
    
    init() {
        setupTableViewHelper()
        setupTextFieldHelper()
    }
    
    func didTapSetTrackerScheduleButton() {
//        let vc = SetTrackerScheduleViewController()
        print("Расписание tapped")
    }
    
    func didChangeTrackerTitleTextField(text: String?) {
        guard let text = text, text.count < 38 else {
            view?.showErrorLabel()
            return
        }
        
        view?.hideErrorLabel()
        self.trackerTitle = text
    }
}

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
}
