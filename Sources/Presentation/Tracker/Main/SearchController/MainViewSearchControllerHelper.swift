import UIKit

protocol MainViewSearchControllerHelperProtocol: UISearchTextFieldDelegate,
                                                 UISearchResultsUpdating,
                                                 UISearchBarDelegate {
    var presenter: MainViewPresetnerSearchControllerProtocol? { get set }
}

final class MainViewSearchControllerHelper: NSObject, MainViewSearchControllerHelperProtocol {
    weak var presenter: MainViewPresetnerSearchControllerProtocol?

    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let text = searchBar.text, !text.isEmpty else { return }
        self.presenter?.requestFilteredTrackers(for: text)
    }

    func searchBarCancelButtonClicked(_: UISearchBar) {
        self.presenter?.requestShowAllCategoriesForCurrentDay()
    }
}
