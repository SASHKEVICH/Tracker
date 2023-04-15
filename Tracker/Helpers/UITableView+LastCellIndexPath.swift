//
//  UITableView+LastCellIndexPath.swift
//  Tracker
//
//  Created by Александр Бекренев on 15.04.2023.
//

import UIKit

extension UITableView {
    var lastCellIndexPath: IndexPath? {
        for section in (0..<self.numberOfSections).reversed() {
            let rows = numberOfRows(inSection: section)
            guard rows > 0 else { continue }
            return IndexPath(row: rows - 1, section: section)
        }
        return nil
    }
}
