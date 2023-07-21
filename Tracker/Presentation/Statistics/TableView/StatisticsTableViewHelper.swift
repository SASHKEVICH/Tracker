//
//  StatisticsTableViewHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 17.07.2023.
//

import UIKit

protocol StatisticsTableViewHelperDelegate: AnyObject {
	var statistics: [Statistics] { get }
}

protocol StatisticsTableViewHelperProtocol: UITableViewDataSource, UITableViewDelegate {
	var delegate: StatisticsTableViewHelperDelegate? { get set }
}

final class StatisticsTableViewHelper: NSObject {
	weak var delegate: StatisticsTableViewHelperDelegate?
}

extension StatisticsTableViewHelper: StatisticsTableViewHelperProtocol {

	// MARK: - UITableViewDelegate
	func tableView(
		_ tableView: UITableView,
		heightForRowAt indexPath: IndexPath
	) -> CGFloat {
		102
	}

	// MARK: - UITableViewDataSource
	func tableView(
		_ tableView: UITableView,
		numberOfRowsInSection section: Int
	) -> Int {
		guard let delegate = self.delegate else {
			assertionFailure("Delegate is nil")
			return 0
		}

		return delegate.statistics.count
	}

	func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(
			withIdentifier: StatisticsTableViewCell.reuseIdentifier,
			for: indexPath
		) as? StatisticsTableViewCell
		else { return UITableViewCell() }

		guard let statistics = self.delegate?.statistics[indexPath.row] else { return UITableViewCell() }
		cell.count = "\(statistics.count)"
		cell.title = statistics.title
		return cell
	}
}
