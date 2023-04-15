//
//  TrackerOptionsTableViewHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 15.04.2023.
//

import UIKit

protocol TrackerOptionsTableViewHelperProtocol: UITableViewDataSource, UITableViewDelegate {
    var presenter: AddTrackerViewPresenterTableViewHelperProtocol? { get set }
}

final class TrackerOptionsTableViewHelper: NSObject, TrackerOptionsTableViewHelperProtocol {
    weak var presenter: AddTrackerViewPresenterTableViewHelperProtocol?
    
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
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TrackerOptionsTableViewCell.identifier, for: indexPath) as? TrackerOptionsTableViewCell,
            let optionsTitles = presenter?.optionsTitles
        else { return UITableViewCell() }
        
        cell.cellTitle = optionsTitles[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        
        if optionsTitles.count == 1 {
            return cell.setupSingleCellInTableView(tableViewWidth: tableView.bounds.width)
        }
        
        if indexPath.row == 0 {
            return cell.setupFirstCellInTableView()
        }
        
        if indexPath == tableView.lastCellIndexPath {
            return cell.setupLastCellWithoutBottomSeparator(tableViewWidth: tableView.bounds.width)
        }
        
        return cell
    }
}

