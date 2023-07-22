//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.03.2023.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

	private let firstLaunchService: FirstLaunchServiceProtocol = FirstLaunchService()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
		self.window = UIWindow(windowScene: scene)

		let isAppAlreadyLaunchedOnce = firstLaunchService.isAppAlreadyLaunchedOnce
		if !isAppAlreadyLaunchedOnce {
			let onboardingHelper = OnboardingViewControllerHelper()
			let onboardingRouter = OnboardingRouter(window: window)
			let onboardingPresenter = OnboardingViewPresenter(helper: onboardingHelper, router: onboardingRouter)
			let onboardingViewController = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

			onboardingViewController.presenter = onboardingPresenter
			onboardingPresenter.view = onboardingViewController

			self.setRootViewController(onboardingViewController)
		} else {
			let tabBarViewController = TabBarViewController()
			self.setRootViewController(tabBarViewController)
		}
    }
}

private extension SceneDelegate {
	func setRootViewController(_ vc: UIViewController) {
		self.window?.rootViewController = vc
		self.window?.makeKeyAndVisible()
	}
}
