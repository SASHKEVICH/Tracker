//
//  TrackerNewCategoryViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation

protocol TrackerNewCategoryViewModelProtocol {
	var onIsAddNewCategoryButtonDisabledChanged: ((Bool) -> Void)? { get set }
	var isAddNewCategoryButtonDisabled: Bool { get }
}

final class TrackerNewCategoryViewModel {
	var onIsAddNewCategoryButtonDisabledChanged: ((Bool) -> Void)?
	var isAddNewCategoryButtonDisabled: Bool = false
}

extension TrackerNewCategoryViewModel: TrackerNewCategoryViewModelProtocol {
	
}
