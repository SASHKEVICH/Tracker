//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.03.2023.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: scene)

        let navigationController = UINavigationController()
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()

        guard let serviceSetupper = self.prepareServiceSetupper() else { return }
        let firstLaunchService = FirstLaunchService()

        let appCoordinator = AppCoordinator(
            navigationController,
            firstLaunchService: firstLaunchService,
            serviceSetupper: serviceSetupper
        )
        appCoordinator.start()
    }
}

private extension SceneDelegate {
    func setRootViewController(_ vc: UIViewController) {
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }

    func prepareServiceSetupper() -> ServiceSetupperProtocol? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let trackersDataStore = appDelegate.trackersDataStore,
              let trackersCategoryDataStore = appDelegate.trackersCategoryDataStore,
              let trackersRecordDataStore = appDelegate.trackersRecordDataStore
        else { return nil }

        let trackersFactory = TrackersFactory()
        let trackersCategoryFactory = TrackersCategoryFactory(trackersFactory: trackersFactory)

        let serviceSetupper = ServiceSetupper(
            trackersFactory: trackersFactory,
            trackersCategoryFactory: trackersCategoryFactory,
            trackersDataStore: trackersDataStore,
            trackersCategoryDataStore: trackersCategoryDataStore,
            trackersRecordDataStore: trackersRecordDataStore
        )
        return serviceSetupper
    }
}
