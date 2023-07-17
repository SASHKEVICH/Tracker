//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 17.07.2023.
//

import Foundation

protocol StatisticsViewModelProtocol {
	var onStatisticsChanged: (() -> Void)? { get set }
	var statistics: [Statistics] { get }

	var onIsPlaceholderHiddenChanged: (() -> Void)? { get set }
	var isPlaceholderHidden: Bool { get }

	var onTrackersCompletedCountChanged: (() -> Void)? { get set }
	var trackersCompletedCount: String? { get }
}

final class StatisticsViewModel {
	var onStatisticsChanged: (() -> Void)?
	var onIsPlaceholderHiddenChanged: (() -> Void)?
	var onTrackersCompletedCountChanged: (() -> Void)?

	var statistics: [Statistics] = [Statistics(title: R.string.localizable.statisticsStatisticTrackersCompletedTitle(), count: 0)] {
		didSet {
			self.onStatisticsChanged?()
		}
	}

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

	private let trackersRecordService: TrackersRecordServiceProtocol

	init(trackersRecordService: TrackersRecordServiceProtocol) {
		self.trackersRecordService = trackersRecordService
	}
}

// MARK: - StatisticsViewModelProtocol
extension StatisticsViewModel: StatisticsViewModelProtocol {
	
}

extension StatisticsViewModel: TrackersRecordStatisticsDelegate {
	func didChanged(completedTrackers: Int) {
		self.trackersCompletedCount = "\(completedTrackers)"
	}
}
