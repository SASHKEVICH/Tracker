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
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: scene)

        let appFactory = AppFactory()
        let screenFactory = ScreenFactory(appFactory: appFactory)

        let coordinatorFactory = CoordinatorFactory(
            window: window,
            appFactory: appFactory,
            screenFactory: screenFactory
        )

        let appCoordinator = coordinatorFactory.makeAppCoordinator()

        appCoordinator.start()

        self.appCoordinator = appCoordinator
        self.window = window
    }
}
