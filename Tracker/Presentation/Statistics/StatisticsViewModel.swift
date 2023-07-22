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

    func fetchCompletedTrackers()
}

final class StatisticsViewModel {
    var onStatisticsChanged: (() -> Void)?
    var onIsPlaceholderHiddenChanged: (() -> Void)?

    var statistics: Set<Statistics> = [] {
        didSet {
            onStatisticsChanged?()
        }
    }

    var isPlaceholderHidden: Bool = false {
        didSet {
            onIsPlaceholderHiddenChanged?()
        }
    }

    private let trackersCompletingService: TrackersCompletingServiceStatisticsProtocol

    init(trackersCompletingService: TrackersCompletingServiceStatisticsProtocol) {
        self.trackersCompletingService = trackersCompletingService
        fetchCompletedTrackers()
    }
}

// MARK: - StatisticsViewModelProtocol

extension StatisticsViewModel: StatisticsViewModelProtocol {
    func fetchCompletedTrackers() {
        let completedTrackersCount = trackersCompletingService.completedTrackersCount
        guard completedTrackersCount > 0 else {
            isPlaceholderHidden = false
            return
        }

        let title = R.string.localizable.statisticsStatisticTrackersCompletedTitle()
        let statistics = Statistics(title: title, count: completedTrackersCount)
        self.statistics.insert(statistics)

        isPlaceholderHidden = true
    }
}

// MARK: - TrackersCompletingServiceStatisticsDelegate

extension StatisticsViewModel: TrackersCompletingServiceStatisticsDelegate {
    func didChangeCompletedTrackers() {
        let completedTrackersCount = trackersCompletingService.completedTrackersCount
        guard completedTrackersCount > 0 else {
            isPlaceholderHidden = false
            return
        }

        let title = R.string.localizable.statisticsStatisticTrackersCompletedTitle()
        let newStatistics = Statistics(title: title, count: completedTrackersCount)

        guard let completedTrackersStatistics = statistics.first(where: { $0.title == title }) else { return }
        statistics.remove(completedTrackersStatistics)
        statistics.insert(newStatistics)

        isPlaceholderHidden = true
    }
}
