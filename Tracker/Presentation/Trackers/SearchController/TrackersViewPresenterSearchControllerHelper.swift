//
//  TrackersViewPresenterSearchFieldDelegate.swift
//  Tracker
//
//  Created by Александр Бекренев on 09.04.2023.
//

import UIKit

protocol TrackersViewPresenterSearchControllerDelegateProtocol: UISearchTextFieldDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    var presenter: TrackersViewPresetnerSearchControllerProtocol? { get set }
}

final class TrackersViewPresenterSearchControllerHelper: NSObject, TrackersViewPresenterSearchControllerDelegateProtocol {
    weak var presenter: TrackersViewPresetnerSearchControllerProtocol?
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let text = searchBar.text, !text.isEmpty else { return }
        presenter?.requestFilteredTrackers(for: text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter?.requestShowAllCategoriesForCurrentDay()
    }
}
