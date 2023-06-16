//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.03.2023.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
		
		let onboardingHelper = OnboardingViewControllerHelper()
		let onboardingPresenter = OnboardingViewPresenter(helper: onboardingHelper)
		let onboardingViewController = OnboardingViewController(
			transitionStyle: .scroll,
			navigationOrientation: .horizontal
		)
		
		onboardingViewController.presenter = onboardingPresenter
		onboardingPresenter.view = onboardingViewController
		
        window?.rootViewController = onboardingViewController
        window?.makeKeyAndVisible()
    }
}

