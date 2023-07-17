//
//  TrackersServiceStub.swift
//  TrackerTests
//
//  Created by Александр Бекренев on 17.07.2023.
//

import UIKit
import Tracker

final class TrackersServiceStub {
	enum State {
		case empty
		case notEmpty
	}

	var trackersDataProviderDelegate: TrackersDataProviderDelegate?

	private let trackersFactory: TrackersFactory = TrackersFactory()
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

	func fetchTrackers(weekDay: WeekDay) {}
	func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay) {}
	func requestDataProviderErrorAlert() {}
	func eraseOperations() {}
}

// MARK: - TrackersServiceFilteringProtocol
extension TrackersServiceStub: TrackersServiceFilteringProtocol {
	func performFiltering(mode: TrackerFilterViewModel.FilterMode) {}
}

// MARK: - TrackersServiceDataSourceProtocol
extension TrackersServiceStub: TrackersServiceDataSourceProtocol {
	var numberOfSections: Int {
		self.state == .empty ? 0 : 1
	}

	func numberOfItemsInSection(_ section: Int) -> Int {
		self.state == .empty ? 0 : 1
	}

	func categoryTitle(at indexPath: IndexPath) -> String? {
		"Test"
	}
}
