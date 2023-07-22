//
//  TrackersPinningService.swift
//  Tracker
//
//  Created by Александр Бекренев on 13.07.2023.
//

import UIKit

public protocol TrackersPinningServiceProtocol {
    func pin(tracker: Tracker)
    func unpin(tracker: Tracker)
}

final class TrackersPinningService {
    private let trackersDataPinner: TrackersDataPinnerProtocol
    private let trackersFactory: TrackersFactory

    init(
        trackersFactory: TrackersFactory,
        trackersDataPinner: TrackersDataPinnerProtocol
    ) {
        self.trackersFactory = trackersFactory
        self.trackersDataPinner = trackersDataPinner
    }
}

// MARK: - TrackersPinningServiceProtocol

extension TrackersPinningService: TrackersPinningServiceProtocol {
    func pin(tracker: Tracker) {
        let pinnedTracker = trackersFactory.makeTracker(
            id: tracker.id,
            type: tracker.type,
            title: tracker.title,
            color: tracker.color,
            emoji: tracker.emoji,
            previousCategoryId: tracker.previousCategoryId,
            isPinned: true,
            schedule: tracker.schedule
        )
        trackersDataPinner.pin(tracker: pinnedTracker)
    }

    func unpin(tracker: Tracker) {
        let unpinnedTracker = trackersFactory.makeTracker(
            id: tracker.id,
            type: tracker.type,
            title: tracker.title,
            color: tracker.color,
            emoji: tracker.emoji,
            previousCategoryId: tracker.previousCategoryId,
            isPinned: false,
            schedule: tracker.schedule
        )
        trackersDataPinner.unpin(tracker: unpinnedTracker)
    }
}
