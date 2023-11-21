import Foundation

protocol SelectingSchedulePresenterProtocol: AnyObject {
    var view: SelectingScheduleViewControllerProtocol? { get set }
    var scheduleTableViewHelper: SelectingScheduleTableViewHelperProtocol? { get set }
    var weekDays: [WeekDay] { get }
    var selectedWeekDays: Set<WeekDay> { get }
    func didChangeSwitchValue(weekDay: WeekDay, isOn: Bool)
}

final class SelectingSchedulePresenter {
    weak var view: SelectingScheduleViewControllerProtocol?
    var scheduleTableViewHelper: SelectingScheduleTableViewHelperProtocol?

    var weekDays: [WeekDay] = WeekDay.allCases
    var selectedWeekDays: Set<WeekDay> = []

    init() {
        self.setupScheduleTableViewHelper()
    }
}

// MARK: - SelectingSchedulePresenterProtocol

extension SelectingSchedulePresenter: SelectingSchedulePresenterProtocol {
    func didChangeSwitchValue(weekDay: WeekDay, isOn: Bool) {
        if isOn {
            self.selectedWeekDays.insert(weekDay)
        } else {
            self.selectedWeekDays.remove(weekDay)
        }
    }
}

private extension SelectingSchedulePresenter {
    func setupScheduleTableViewHelper() {
        let scheduleTableViewHelper = SelectingScheduleTableViewHelper()
        scheduleTableViewHelper.presenter = self
        self.scheduleTableViewHelper = scheduleTableViewHelper
    }
}
