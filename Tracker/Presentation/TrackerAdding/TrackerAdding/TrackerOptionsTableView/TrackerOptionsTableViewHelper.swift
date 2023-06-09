//
//  TrackerOptionsTableViewHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 15.04.2023.
//

import UIKit

protocol TrackerOptionsTableViewHelperProtocol: UITableViewDataSource, UITableViewDelegate {
    var presenter: TrackerAddingViewPresenterTableViewHelperProtocol? { get set }
}

final class TrackerOptionsTableViewHelper: NSObject, TrackerOptionsTableViewHelperProtocol {
    weak var presenter: TrackerAddingViewPresenterTableViewHelperProtocol?
    
    // MARK: UITableViewDelegate    
    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        75
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? TrackerOptionsTableViewCell else { return }
        
		if cell.type == .schedule {
            presenter?.didTapTrackerScheduleCell()
		} else if cell.type == .category {
			presenter?.didTapTrackerCategoryCell()
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        guard let optionsTitles = presenter?.optionsTitles else {
            assertionFailure("presenter or options titles is nil")
            return 0
        }
        return optionsTitles.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
			withIdentifier: TrackerOptionsTableViewCell.reuseIdentifier,
			for: indexPath) as? TrackerOptionsTableViewCell
		else { return UITableViewCell() }

		guard let optionsTitles = presenter?.optionsTitles else { return UITableViewCell() }
        
		cell.set(cellTitle: optionsTitles[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        
        configureAdditionalInfo(for: cell)

		let configuredCell = cell.configure(
			cellIndexPath: indexPath,
			lastCellIndexPath: tableView.lastCellIndexPath,
			entityCount: optionsTitles.count,
			tableViewWidth: tableView.bounds.width)
        
        return configuredCell
    }
}

// MARK: - Configuring additional info for cell
private extension TrackerOptionsTableViewHelper {
    func configureAdditionalInfo(for cell: TrackerOptionsTableViewCell) {
		if cell.type == .schedule {
			self.configureSchduleAdditionalInfo(for: cell)
		} else if cell.type == .category {
			self.configureCategoryAdditionalInfo(for: cell)
		}
    }
    
    func configureSchduleAdditionalInfo(for cell: TrackerOptionsTableViewCell) {
        guard let selectedWeekDays = presenter?.selectedWeekDays, !selectedWeekDays.isEmpty else {
			cell.set(additionalInfo: nil)
			return
		}

        let selectedWeekDaysArray = Array(selectedWeekDays).sorted()
        
        guard selectedWeekDaysArray.count != 7 else {
			cell.set(additionalInfo: "Каждый день")
            return
        }
        
        let additionalInfo = selectedWeekDaysArray.reduce("") { (result: String, weekDay: WeekDay) in result + weekDay.shortStringRepresentaion + ", " }
        cell.set(additionalInfo: String(additionalInfo.prefix(additionalInfo.count - 2)))
    }

	func configureCategoryAdditionalInfo(for cell: TrackerOptionsTableViewCell) {
		guard let selectedCategory = self.presenter?.selectedCategory else {
			cell.set(additionalInfo: nil)
			return
		}
		cell.set(additionalInfo: selectedCategory.title)
	}
}
