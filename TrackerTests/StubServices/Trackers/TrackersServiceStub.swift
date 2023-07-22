//
//  TrackersServiceStub.swift
//  TrackerTests
//
//  Created by Александр Бекренев on 17.07.2023.
//

import Tracker
import UIKit

final class TrackersServiceStub {
    enum State {
        case empty
        case notEmpty
    }

    weak var trackersDataProviderDelegate: TrackersDataProviderDelegate?

    private let trackersFactory: TrackersFactory = .init()
    private let state: State

    init(state: State) {
        self.state = state
    }
}

// MARK: - TrackersServiceFetchingProtocol

extension TrackersServiceStub: TrackersServiceFetchingProtocol {
    var trackers: [Tracker] {
        let tracker = self.trackersFactory.makeTracker(
            type: .irregularEvent,
            title: "Test",
            color: .systemBlue,
            emoji: "😤",
            previousCategoryId: UUID(),
            isPinned: false,
            schedule: WeekDay.allCases
        )

        return self.state == .empty ? [] : [tracker]
    }

    func tracker(at _: IndexPath) -> Tracker? {
        let tracker = self.trackersFactory.makeTracker(
            type: .irregularEvent,
            title: "Test",
            color: .systemBlue,
            emoji: "😤",
            previousCategoryId: UUID(),
            isPinned: false,
            schedule: WeekDay.allCases
        )

        return self.state == .empty ? nil : tracker
    }

    func fetchTrackers(weekDay _: WeekDay) {}
    func fetchTrackers(titleSearchString _: String, currentWeekDay _: WeekDay) {}
    func requestDataProviderErrorAlert() {}
    func eraseOperations() {}
}

// MARK: - TrackersServiceFilteringProtocol

extension TrackersServiceStub: TrackersServiceFilteringProtocol {
    func performFiltering(mode _: TrackerFilterViewModel.FilterMode) {}
}

// MARK: - TrackersServiceDataSourceProtocol

extension TrackersServiceStub: TrackersServiceDataSourceProtocol {
    var numberOfSections: Int {
        self.state == .empty ? 0 : 1
    }

    func numberOfItemsInSection(_: Int) -> Int {
        self.state == .empty ? 0 : 1
    }

    func categoryTitle(at _: IndexPath) -> String? {
        "Test"
    }
}
