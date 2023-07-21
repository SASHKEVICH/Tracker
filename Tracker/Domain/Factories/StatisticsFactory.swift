//
//  StatisticsFactory.swift
//  Tracker
//
//  Created by Александр Бекренев on 17.07.2023.
//

import Foundation

struct StatisticsFactory {
	func makeStatistics(title: String, count: Int) -> Statistics {
		Statistics(title: title, count: count)
	}
}
