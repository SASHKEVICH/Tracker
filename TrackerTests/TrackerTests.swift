//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Александр Бекренев on 17.07.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
	func testStatisticsScreen() throws {
		let service = TrackersCompletingServiceStub()
		let viewModel = StatisticsViewModel(trackersCompletingService: service)

		service.delegate = viewModel

		let tableViewHelper = StatisticsTableViewHelper()
		let vc = StatisticsViewController(viewModel: viewModel, tableViewHelper: tableViewHelper)

		tableViewHelper.delegate = vc

		assertSnapshots(matching: vc, as: [
			.image(traits: UITraitCollection(userInterfaceStyle: .light))
		])
		assertSnapshots(matching: vc, as: [
			.image(traits: UITraitCollection(userInterfaceStyle: .dark))
		])
	}
}
