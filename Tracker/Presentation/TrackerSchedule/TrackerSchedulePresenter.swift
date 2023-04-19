//
//  TrackerSchedulePresenter.swift
//  Tracker
//
//  Created by Александр Бекренев on 18.04.2023.
//

import Foundation

protocol TrackerSchedulePresenterProtocol: AnyObject {
    var view: TrackerScheduleViewControllerProtocol? { get set }
    var scheduleTableViewHelper: TrackerScheduleTableViewHelperProtocol? { get set }
    var weekDays: [WeekDay] { get }
    var selectedWeekDays: Set<WeekDay> { get }
    func didChangeSwitchValue(weekDay: WeekDay, isOn: Bool)
}

final class TrackerSchedulePresenter: TrackerSchedulePresenterProtocol {
    var view: TrackerScheduleViewControllerProtocol?
    var scheduleTableViewHelper: TrackerScheduleTableViewHelperProtocol?
    
    var weekDays: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    var selectedWeekDays: Set<WeekDay> = []
    
    init() {
        setupScheduleTableViewHelper()
    }
}

extension TrackerSchedulePresenter {
    func didChangeSwitchValue(weekDay: WeekDay, isOn: Bool) {
        if isOn {
            selectedWeekDays.insert(weekDay)
        } else {
            selectedWeekDays.remove(weekDay)
        }
    }
}

private extension TrackerSchedulePresenter {
    func setupScheduleTableViewHelper() {
        let scheduleTableViewHelper = TrackerScheduleTableViewHelper()
        scheduleTableViewHelper.presenter = self
        self.scheduleTableViewHelper = scheduleTableViewHelper
    }
}
