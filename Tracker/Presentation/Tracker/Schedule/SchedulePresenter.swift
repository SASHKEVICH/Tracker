import Foundation

protocol SchedulePresenterProtocol: AnyObject {
    var view: ScheduleViewControllerProtocol? { get set }
    var scheduleTableViewHelper: TrackerScheduleTableViewHelperProtocol? { get set }
    var weekDays: [WeekDay] { get }
    var selectedWeekDays: Set<WeekDay> { get }
    func didChangeSwitchValue(weekDay: WeekDay, isOn: Bool)
}

final class SchedulePresenter {
    weak var view: ScheduleViewControllerProtocol?
    var scheduleTableViewHelper: TrackerScheduleTableViewHelperProtocol?

    var weekDays: [WeekDay] = WeekDay.allCases
    var selectedWeekDays: Set<WeekDay> = []

    init() {
        self.setupScheduleTableViewHelper()
    }
}

// MARK: - SchedulePresenterProtocol

extension SchedulePresenter: SchedulePresenterProtocol {
    func didChangeSwitchValue(weekDay: WeekDay, isOn: Bool) {
        if isOn {
            self.selectedWeekDays.insert(weekDay)
        } else {
            self.selectedWeekDays.remove(weekDay)
        }
    }
}

private extension SchedulePresenter {
    func setupScheduleTableViewHelper() {
        let scheduleTableViewHelper = TrackerScheduleTableViewHelper()
        scheduleTableViewHelper.presenter = self
        self.scheduleTableViewHelper = scheduleTableViewHelper
    }
}
