//
//  AddTrackerViewPresenter.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.04.2023.
//

import Foundation

protocol AddTrackerViewPresenterTableViewHelperProtocol: AnyObject {
    var optionsTitles: [String]? { get }
}

protocol AddTrackerViewPresenterProtocol: AnyObject, AddTrackerViewPresenterTableViewHelperProtocol {
    var view: AddTrackerViewControllerProtocol? { get set }
    var tableViewHelper: TrackerOptionsTableViewHelperProtocol? { get }
    func viewDidLoad(type: TrackerType)
}

final class AddTrackerViewPresenter: AddTrackerViewPresenterProtocol {
    weak var view: AddTrackerViewControllerProtocol?
    
    var optionsTitles: [String]?
    
    var tableViewHelper: TrackerOptionsTableViewHelperProtocol?
    
    func viewDidLoad(type: TrackerType) {
        setupOptionsTitles(type: type)
    }
    
    init() {
        setupTableViewHelper()
    }
}

private extension AddTrackerViewPresenter {
    func setupTableViewHelper() {
        let tableViewHelper = TrackerOptionsTableViewHelper()
        tableViewHelper.presenter = self
        self.tableViewHelper = tableViewHelper
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
