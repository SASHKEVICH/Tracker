import Foundation

protocol StatisticsViewModelProtocol {
    var statistics: Box<Set<Statistics>> { get }
    var isPlaceholderHidden: Box<Bool> { get }

    func fetchCompletedTrackers()
}

final class StatisticsViewModel {
    var statistics = Box<Set<Statistics>>([])
    var isPlaceholderHidden = Box<Bool>(false)

    private let trackersCompletingService: TrackersCompletingServiceStatisticsProtocol

    init(trackersCompletingService: TrackersCompletingServiceStatisticsProtocol) {
        self.trackersCompletingService = trackersCompletingService
        self.fetchCompletedTrackers()
    }
}

// MARK: - StatisticsViewModelProtocol

extension StatisticsViewModel: StatisticsViewModelProtocol {
    func fetchCompletedTrackers() {
        let completedTrackersCount = self.trackersCompletingService.completedTrackersCount
        guard completedTrackersCount > 0 else {
            self.isPlaceholderHidden.value = false
            return
        }

        let title = R.string.localizable.statisticsStatisticTrackersCompletedTitle()
        let statistics = Statistics(title: title, count: completedTrackersCount)
        self.statistics.value.insert(statistics)

        self.isPlaceholderHidden.value = true
    }
}

// MARK: - TrackersCompletingServiceStatisticsDelegate

extension StatisticsViewModel: TrackersCompletingServiceStatisticsDelegate {
    func didChangeCompletedTrackers() {
        let completedTrackersCount = self.trackersCompletingService.completedTrackersCount
        guard completedTrackersCount > 0 else {
            self.isPlaceholderHidden.value = false
            return
        }

        let title = R.string.localizable.statisticsStatisticTrackersCompletedTitle()
        let newStatistics = Statistics(title: title, count: completedTrackersCount)

        guard let completedTrackersStatistics = self.statistics.value.first(where: { $0.title == title }) else { return }
        self.statistics.value.remove(completedTrackersStatistics)
        self.statistics.value.insert(newStatistics)

        self.isPlaceholderHidden.value = true
    }
}
