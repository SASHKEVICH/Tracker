//
//  FirstLaunchService.swift
//  Tracker
//
//  Created by Александр Бекренев on 16.06.2023.
//

import Foundation

protocol FirstLaunchServiceProtocol {
	var isAppAlreadyLaunchedOnce: Bool { get }
}

// MARK: - FirstLaunchService
final class FirstLaunchService {
	private let userDefaults = UserDefaults.standard
	private let key = "isAppAlreadyLaunchedOnce"
}

// MARK: - FirstLaunchServiceProtocol
extension FirstLaunchService: FirstLaunchServiceProtocol {
	var isAppAlreadyLaunchedOnce: Bool {
		let launchCount = userDefaults.integer(forKey: key)
		if launchCount == 0 {
			userDefaults.set(launchCount + 1, forKey: key)
			return false
		} else {
			return true
		}
	}
}
