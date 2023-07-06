//
//  TrackerCategoryTableViewHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 19.06.2023.
//

import UIKit

protocol TrackerCategoryTableViewHelperDelegate {
	var categories: [TrackerCategory] { get }
	func didTapCategoryCell(category: TrackerCategory)
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
//		delegate?.didTapCategoryCell(category: cell.category)
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

		guard let lastSelectedCell = self.lastSelectedCell else { return cell }

		if lastSelectedCell == cell {
			cell.isCellSelected = true
			self.lastSelectedCell = cell
		}

		return cell
	}
}
