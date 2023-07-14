//
//  TrackerCategoryTableViewHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 19.06.2023.
//

import UIKit

protocol TrackerCategoryTableViewHelperDelegate {
	var categories: [TrackerCategory] { get }
	func didChoose(category: TrackerCategory)
}

protocol TrackerCategoryTableViewHelperProtocol: UITableViewDelegate, UITableViewDataSource {
	var delegate: TrackerCategoryTableViewHelperDelegate? { get set }
}

final class TrackerCategoryTableViewHelper: NSObject, TrackerCategoryTableViewHelperProtocol {
	var delegate: TrackerCategoryTableViewHelperDelegate?
	
	private var lastSelectedCell: TrackerCategoryTableViewCell?
	
	// MARK: - UITableViewDelegate
	func tableView(
		_ tableView: UITableView,
		didSelectRowAt indexPath: IndexPath
	) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		guard let cell = tableView.cellForRow(at: indexPath) as? TrackerCategoryTableViewCell else { return }
		guard let cells = tableView.visibleCells as? [TrackerCategoryTableViewCell] else { return }

		if cell != self.lastSelectedCell {
			cell.isCellSelected = true
			self.lastSelectedCell = cell

			let filteredCells = cells.filter { $0 != cell }
			filteredCells.forEach { $0.isCellSelected = false }
		}

		guard let chosenCategory = delegate?.categories[indexPath.row] else { return }
		delegate?.didChoose(category: chosenCategory)
	}
	
	// MARK: - UITableViewDataSource
	func tableView(
		_ tableView: UITableView,
		numberOfRowsInSection section: Int
	) -> Int {
		delegate?.categories.count ?? .zero
	}
	
	func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(
			withIdentifier: TrackerCategoryTableViewCell.reuseIdentifier,
			for: indexPath
		) as? TrackerCategoryTableViewCell else { return UITableViewCell() }

		guard let category = delegate?.categories[indexPath.row] else { return UITableViewCell() }
		cell.categoryTitle = category.title

		if let lastSelectedCell = self.lastSelectedCell, lastSelectedCell == cell {
			cell.isCellSelected = true
		}

		let configuredCell = cell.configure(
			cellIndexPath: indexPath,
			lastCellIndexPath: tableView.lastCellIndexPath,
			entityCount: delegate?.categories.count,
			tableViewWidth: tableView.bounds.width
		)

		return configuredCell
	}
}
