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

	private var defaultSeparatorInsets: UIEdgeInsets {
		UIEdgeInsets.TableViewSeparator.insets
	}

	func configure(
		cellIndexPath: IndexPath,
		lastCellIndexPath: IndexPath?,
		entityCount: Int?,
		tableViewWidth: CGFloat
	) -> UITableViewCell {
		self.separatorInset = self.defaultSeparatorInsets

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

	func cleanUp() {
		self.layer.cornerRadius = 0
		self.layer.maskedCorners = []
		self.selectedBackgroundView?.layer.cornerRadius = 0
		self.selectedBackgroundView?.layer.maskedCorners = []
		self.separatorInset = .zero
	}
}

private extension UITableViewCell {
	func setupFirstCellInTableView() -> UITableViewCell {
		self.layer.masksToBounds = true
		self.layer.cornerRadius = 16
		self.selectedBackgroundView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		return self
	}

	func setupLastCellWithoutBottomSeparator(
		tableViewWidth: CGFloat
	) -> UITableViewCell {
		self.layer.masksToBounds = true
		self.layer.cornerRadius = 16
		self.selectedBackgroundView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		self.separatorInset = UIEdgeInsets(
			top: defaultSeparatorInsets.top,
			left: tableViewWidth + 1,
			bottom: defaultSeparatorInsets.bottom,
			right: 0)
		return self
	}

	func setupSingleCellInTableView(
		tableViewWidth: CGFloat
	) -> UITableViewCell {
		self.layer.masksToBounds = true
		self.layer.cornerRadius = 16
		let defaultInsets = UIEdgeInsets.TableViewSeparator.insets
		self.separatorInset = UIEdgeInsets(
			top: defaultSeparatorInsets.top,
			left: tableViewWidth + 1,
			bottom: defaultSeparatorInsets.bottom,
			right: 0)
		return self
	}
}
