//
//  TrackersAddingServiceStub.swift
//  TrackerTests
//
//  Created by Александр Бекренев on 17.07.2023.
//

import Tracker
import UIKit

final class TrackersAddingServiceStub {}

// MARK: - TrackersAddingServiceProtocol

extension TrackersAddingServiceStub: TrackersAddingServiceProtocol {
    func addTracker(
        title _: String,
        schedule _: Set<WeekDay>,
        type _: Tracker.TrackerType,
        color _: UIColor,
        emoji _: String,
        categoryId _: UUID
    ) {}

    func delete(tracker _: Tracker) {}

    func saveEdited(
        trackerId _: UUID,
        title _: String,
        schedule _: Set<WeekDay>,
        type _: Tracker.TrackerType,
        color _: UIColor,
        emoji _: String,
        newCategoryId _: UUID,
        previousCategoryId _: UUID,
        isPinned _: Bool
    ) {}
}
