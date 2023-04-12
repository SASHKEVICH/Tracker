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

final class TrackersViewPresenterSearchControllerDelegate: NSObject, TrackersViewPresenterSearchControllerDelegateProtocol {
    weak var presenter: TrackersViewPresetnerSearchControllerProtocol?
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        presenter?.requestFilteredTrackers(for: searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter?.requestShowAllCategoriesForCurrentDay()
    }
}
