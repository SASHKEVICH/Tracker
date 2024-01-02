import UIKit

protocol CategoryTableViewHelperDelegate: AnyObject {
    var categories: [CategoryViewController.Model] { get }
    var chosenCategory: Category? { get }
    func didSelect(category: Category)
}

protocol CategoryTableViewHelperProtocol: UITableViewDelegate, UITableViewDataSource {
    var delegate: CategoryTableViewHelperDelegate? { get set }
}

final class CategoryTableViewHelper: NSObject, CategoryTableViewHelperProtocol {
    weak var delegate: CategoryTableViewHelperDelegate?

    private var lastSelectedCell: CategoryTableViewCell?

    // MARK: - UITableViewDelegate

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell else { return }
        guard let cells = tableView.visibleCells as? [CategoryTableViewCell] else { return }

        if cell != self.lastSelectedCell {
            cell.isCellSelected = true
            self.lastSelectedCell = cell

            let filteredCells = cells.filter { $0 != cell }
            filteredCells.forEach { $0.isCellSelected = false }
        }

        guard let selectedCategory = self.delegate?.categories[indexPath.row] else { return }
//        self.delegate?.didSelect(category: selectedCategory)
    }

    // MARK: - UITableViewDataSource

    func tableView(
        _: UITableView,
        numberOfRowsInSection _: Int
    ) -> Int {
        self.delegate?.categories.count ?? .zero
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryTableViewCell else { return UITableViewCell() }

        guard let category = self.delegate?.categories[indexPath.row] else { return UITableViewCell() }
        cell.categoryTitle = category.title

        if let lastSelectedCell = self.lastSelectedCell, lastSelectedCell == cell {
            cell.isCellSelected = true
        }

//        if let selectedCategory = self.delegate?.chosenCategory, selectedCategory == category {
//            cell.isCellSelected = true
//        }

        let configuredCell = cell.configure(
            cellIndexPath: indexPath,
            lastCellIndexPath: tableView.lastCellIndexPath,
            entityCount: delegate?.categories.count,
            tableViewWidth: tableView.bounds.width
        )

        return configuredCell
    }
}
