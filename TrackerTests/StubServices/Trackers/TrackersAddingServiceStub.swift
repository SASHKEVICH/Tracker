//
//  TrackersAddingServiceStub.swift
//  TrackerTests
//
//  Created by Александр Бекренев on 17.07.2023.
//

import UIKit
import Tracker

final class TrackersAddingServiceStub {}

// MARK: - TrackersAddingServiceProtocol
extension TrackersAddingServiceStub: TrackersAddingServiceProtocol {
	func addTracker(
		title: String,
		schedule: Set<WeekDay>,
		type: Tracker.TrackerType,
		color: UIColor,
		emoji: String,
		categoryId: UUID
	) {}

	func delete(tracker: Tracker) {}

	func saveEdited(
		trackerId: UUID,
		title: String,
		schedule: Set<WeekDay>,
		type: Tracker.TrackerType,
		color: UIColor,
		emoji: String,
		newCategoryId: UUID,
		previousCategoryId: UUID,
		isPinned: Bool
	) {}
}
