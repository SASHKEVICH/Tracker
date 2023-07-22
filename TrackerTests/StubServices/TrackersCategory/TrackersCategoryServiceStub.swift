//
//  TrackersCategoryServiceStub.swift
//  TrackerTests
//
//  Created by Александр Бекренев on 17.07.2023.
//

import Foundation
import Tracker

final class TrackersCategoryServiceStub {
    enum State {
        case empty
        case notEmpty
    }

    weak var trackersCategoryDataProviderDelegate: TrackersCategoryDataProviderDelegate?

    private let state: State
    private let trackersCategoryFactory: TrackersCategoryFactory

    init(state: State) {
        self.state = state
        trackersCategoryFactory = TrackersCategoryFactory(trackersFactory: TrackersFactory())
    }
}

// MARK: - TrackersCategoryServiceProtocol

extension TrackersCategoryServiceStub: TrackersCategoryServiceProtocol {
    var numberOfSections: Int {
        state == .empty ? 0 : 1
    }

    var categories: [TrackerCategory] {
        let category = trackersCategoryFactory.makeCategory(title: "Test", isPinning: false)
        return state == .empty ? [] : [category]
    }

    func numberOfItemsInSection(_: Int) -> Int {
        state == .empty ? 0 : 1
    }

    func category(for _: Tracker) -> TrackerCategory? {
        nil
    }
}
