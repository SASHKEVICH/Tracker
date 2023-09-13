import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let appFactory: AppFactory = DI()
    private var appCoordinator: Coordinator?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        self.start(on: UIWindow(windowScene: scene))
    }
}

private extension SceneDelegate {
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

    func start(on window: UIWindow) {
        let coordinator = self.appFactory.makeKeyWindowWithCoordinator(window: window)
        self.window = window
        self.appCoordinator = coordinator

        window.makeKeyAndVisible()
        coordinator.start()
    }
}
