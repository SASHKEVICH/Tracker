import UIKit

protocol OptionsTableViewDelegate: AnyObject {
    var optionsTitles: [String] { get }
    var selectedWeekDays: [WeekDay] { get }
    var selectedCategory: TrackerCategory? { get }
    func didTapScheduleCell()
    func didTapCategoryCell()
}

protocol OptionsTableViewHelperProtocol: UITableViewDataSource, UITableViewDelegate {
    var delegate: OptionsTableViewDelegate? { get set }
}

final class OptionsTableViewHelper: NSObject, OptionsTableViewHelperProtocol {
    weak var delegate: OptionsTableViewDelegate?

    // MARK: - UITableViewDelegate

    func tableView(
        _: UITableView,
        estimatedHeightForRowAt _: IndexPath
    ) -> CGFloat {
        75
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? OptionsTableViewCell else { return }

        if cell.type == .schedule {
            self.delegate?.didTapScheduleCell()
        } else if cell.type == .category {
            self.delegate?.didTapCategoryCell()
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(
        _: UITableView,
        numberOfRowsInSection _: Int
    ) -> Int {
        guard let optionsTitles = self.delegate?.optionsTitles else {
            assertionFailure("delegate or options titles is nil")
            return 0
        }
        return optionsTitles.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: OptionsTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? OptionsTableViewCell
        else { return UITableViewCell() }

        guard let optionsTitles = self.delegate?.optionsTitles else { return UITableViewCell() }

        cell.set(cellTitle: optionsTitles[indexPath.row])
        cell.accessoryType = .disclosureIndicator

        self.configureAdditionalInfo(for: cell)

        let configuredCell = cell.configure(
            cellIndexPath: indexPath,
            lastCellIndexPath: tableView.lastCellIndexPath,
            entityCount: optionsTitles.count,
            tableViewWidth: tableView.bounds.width
        )

        return configuredCell
    }
}

// MARK: - Configuring additional info for cell

private extension OptionsTableViewHelper {
    func configureAdditionalInfo(for cell: OptionsTableViewCell) {
        if cell.type == .schedule {
            self.configureSchduleAdditionalInfo(for: cell)
        } else if cell.type == .category {
            self.configureCategoryAdditionalInfo(for: cell)
        }
    }

    func configureSchduleAdditionalInfo(for cell: OptionsTableViewCell) {
        guard let selectedWeekDays = self.delegate?.selectedWeekDays, !selectedWeekDays.isEmpty else {
            cell.set(additionalInfo: nil)
            return
        }

        let selectedWeekDaysArray = Array(selectedWeekDays).sorted()

        guard selectedWeekDaysArray.count != 7 else {
            let additionalInfo = R.string.localizable.weekDayAllCases()
            cell.set(additionalInfo: additionalInfo)
            return
        }

        let additionalInfo = selectedWeekDaysArray.reduce("") { (result: String, weekDay: WeekDay) in
            result + weekDay.shortStringRepresentaion + ", "
        }
        cell.set(additionalInfo: String(additionalInfo.prefix(additionalInfo.count - 2)))
    }

    func configureCategoryAdditionalInfo(for cell: OptionsTableViewCell) {
        guard let selectedCategory = self.delegate?.selectedCategory else {
            cell.set(additionalInfo: nil)
            return
        }
        cell.set(additionalInfo: selectedCategory.title)
    }
}
