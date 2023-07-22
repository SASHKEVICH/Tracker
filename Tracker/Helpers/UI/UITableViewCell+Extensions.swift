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
        separatorInset = defaultSeparatorInsets

        if entityCount == 1 {
            return setupSingleCellInTableView(tableViewWidth: tableViewWidth)
        }

        if cellIndexPath.row == 0 {
            return setupFirstCellInTableView()
        }

        if cellIndexPath == lastCellIndexPath {
            return setupLastCellWithoutBottomSeparator(tableViewWidth: tableViewWidth)
        }

        return self
    }

    func cleanUp() {
        layer.cornerRadius = 0
        layer.maskedCorners = []
        selectedBackgroundView?.layer.cornerRadius = 0
        selectedBackgroundView?.layer.maskedCorners = []
        separatorInset = .zero
    }
}

private extension UITableViewCell {
    func setupFirstCellInTableView() -> UITableViewCell {
        layer.masksToBounds = true
        layer.cornerRadius = 16
        selectedBackgroundView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return self
    }

    func setupLastCellWithoutBottomSeparator(
        tableViewWidth: CGFloat
    ) -> UITableViewCell {
        layer.masksToBounds = true
        layer.cornerRadius = 16
        selectedBackgroundView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        separatorInset = UIEdgeInsets(
            top: defaultSeparatorInsets.top,
            left: tableViewWidth + 1,
            bottom: defaultSeparatorInsets.bottom,
            right: 0
        )
        return self
    }

    func setupSingleCellInTableView(
        tableViewWidth: CGFloat
    ) -> UITableViewCell {
        layer.masksToBounds = true
        layer.cornerRadius = 16
        separatorInset = UIEdgeInsets(
            top: defaultSeparatorInsets.top,
            left: tableViewWidth + 1,
            bottom: defaultSeparatorInsets.bottom,
            right: 0
        )
        return self
    }
}
