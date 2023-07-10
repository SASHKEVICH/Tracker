//
//  OnboardingRouter.swift
//  Tracker
//
//  Created by Александр Бекренев on 10.07.2023.
//

import UIKit

protocol OnboardingRouterProtocol {
	func navigateToMainScreen()
}

final class OnboardingRouter {
	private weak var window: UIWindow?

	init(window: UIWindow?) {
		self.window = window
	}
}

// MARK: - OnboardingRouterProtocol
extension OnboardingRouter: OnboardingRouterProtocol {
	func navigateToMainScreen() {
		let tabBarController = TabBarViewController()
		self.window?.rootViewController = tabBarController
		self.window?.makeKeyAndVisible()
	}
}
