//
//  UITableViewCell+TrackerCorners.swift
//  Tracker
//
//  Created by Александр Бекренев on 20.06.2023.
//

import UIKit

extension UITableViewCell {
	static var reuseIdentifier: String {
		String(describing: Self.self)
	}

	func configure(
		cellIndexPath: IndexPath,
		lastCellIndexPath: IndexPath?,
		entityCount: Int?,
		tableViewWidth: CGFloat
	) -> UITableViewCell {
		if entityCount == 1 {
			return self.setupSingleCellInTableView(tableViewWidth: tableViewWidth)
		}

		if cellIndexPath.row == 0 {
			return self.setupFirstCellInTableView()
		}

		if cellIndexPath == lastCellIndexPath {
			return self.setupLastCellWithoutBottomSeparator(tableViewWidth: tableViewWidth)
		}

		return self
	}
}

private extension UITableViewCell {
	func setupFirstCellInTableView() -> UITableViewCell {
		selectedBackgroundView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

		self.layer.masksToBounds = true
		self.layer.cornerRadius = 16
		self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

		return self
	}

	func setupLastCellWithoutBottomSeparator(
		tableViewWidth: CGFloat
	) -> UITableViewCell {
		selectedBackgroundView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

		self.layer.masksToBounds = true
		self.layer.cornerRadius = 16
		self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		self.separatorInset = UIEdgeInsets(
			top: 0,
			left: tableViewWidth + 1,
			bottom: 0,
			right: 0)
		return self
	}

	func setupSingleCellInTableView(
		tableViewWidth: CGFloat
	) -> UITableViewCell {
		self.layer.masksToBounds = true
		self.layer.cornerRadius = 16
		self.separatorInset = UIEdgeInsets(
			top: 0,
			left: tableViewWidth + 1,
			bottom: 0,
			right: 0)
		return self
	}
}
