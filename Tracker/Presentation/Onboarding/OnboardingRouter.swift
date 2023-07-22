//
//  OnboardingRouter.swift
//  Tracker
//
//  Created by Александр Бекренев on 10.07.2023.
//

import UIKit

protocol OnboardingRouterProtocol {
    func navigateToMainScreen(animated: Bool)
}

final class OnboardingRouter {
    private weak var window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
    }
}

// MARK: - OnboardingRouterProtocol

extension OnboardingRouter: OnboardingRouterProtocol {
    func navigateToMainScreen(animated _: Bool) {
        guard let window = self.window else { return }
        let tabBarController = TabBarViewController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )
    }
}
