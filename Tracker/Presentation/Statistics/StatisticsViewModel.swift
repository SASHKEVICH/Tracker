//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 17.07.2023.
//

import Foundation

protocol StatisticsViewModelProtocol {
	var onIsPlaceholderHiddenChanged: (() -> Void)? { get set }
	var isPlaceholderHidden: Bool { get }

	var onTrackersCompletedCountChanged: (() -> Void)? { get set }
	var trackersCompletedCount: String? { get }
}

struct StatisticsViewModel {
	var onIsPlaceholderHiddenChanged: (() -> Void)?
	var onTrackersCompletedCountChanged: (() -> Void)?

	var isPlaceholderHidden: Bool = false {
		didSet {
			self.onIsPlaceholderHiddenChanged?()
		}
	}

	var trackersCompletedCount: String? = nil {
		didSet {
			self.onTrackersCompletedCountChanged?()
		}
	}
}

// MARK: - StatisticsViewModelProtocol
extension StatisticsViewModel: StatisticsViewModelProtocol {
	
}
