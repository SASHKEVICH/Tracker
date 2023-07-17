//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 17.07.2023.
//

import Foundation

protocol StatisticsViewModelProtocol {
	var onStatisticsChanged: (() -> Void)? { get set }
	var statistics: Set<Statistics> { get }

	var onIsPlaceholderHiddenChanged: (() -> Void)? { get set }
	var isPlaceholderHidden: Bool { get }
}

final class StatisticsViewModel {
	var onStatisticsChanged: (() -> Void)?
	var onIsPlaceholderHiddenChanged: (() -> Void)?

	var statistics: Set<Statistics> = [] {
		didSet {
			self.onStatisticsChanged?()
		}
	}

	var isPlaceholderHidden: Bool = false {
		didSet {
			self.onIsPlaceholderHiddenChanged?()
		}
	}

	private let trackersCompletingService: TrackersCompletingServiceStatisticsProtocol

	init(trackersCompletingService: TrackersCompletingServiceStatisticsProtocol) {
		self.trackersCompletingService = trackersCompletingService
		self.fetchCompletedTrackers()
	}
}

// MARK: - StatisticsViewModelProtocol
extension StatisticsViewModel: StatisticsViewModelProtocol {}

extension StatisticsViewModel: TrackersCompletingServiceStatisticsDelegate {
	func didChangeCompletedTrackers() {
		let completedTrackersCount = self.trackersCompletingService.completedTrackersCount
		guard completedTrackersCount > 0 else {
			self.isPlaceholderHidden = false
			return
		}

		let title = R.string.localizable.statisticsStatisticTrackersCompletedTitle()
		let newStatistics = Statistics(title: title, count: completedTrackersCount)

		guard let completedTrackersStatistics = self.statistics.first(where: { $0.title == title }) else { return }
		self.statistics.remove(completedTrackersStatistics)
		self.statistics.insert(newStatistics)

		self.isPlaceholderHidden = true
	}
}

private extension StatisticsViewModel {
	func fetchCompletedTrackers() {
		let completedTrackersCount = self.trackersCompletingService.completedTrackersCount
		guard completedTrackersCount > 0 else { return }

		let title = R.string.localizable.statisticsStatisticTrackersCompletedTitle()
		let statistics = Statistics(title: title, count: completedTrackersCount)
		self.statistics.insert(statistics)

		self.isPlaceholderHidden = true
	}
}
