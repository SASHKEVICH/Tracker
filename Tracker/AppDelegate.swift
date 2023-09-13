import CoreData
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var trackersDataStore: TrackersDataStore? = {
        guard let container = self.persistentContainer else { return nil }
        let trackerDataStore = TrackersDataStore(context: container.viewContext)
        return trackerDataStore
    }()

    lazy var trackersCategoryDataStore: TrackersCategoryDataStore? = {
        guard let container = self.persistentContainer else { return nil }
        let trackerCategoryDataStore = TrackersCategoryDataStore(context: container.viewContext)
        return trackerCategoryDataStore
    }()

    lazy var trackersRecordDataStore: TrackersRecordDataStore? = {
        guard let container = self.persistentContainer else { return nil }
        let trackerRecordDataStore = TrackersRecordDataStore(context: container.viewContext)
        return trackerRecordDataStore
    }()

    private lazy var persistentContainer: NSPersistentContainer? = {
        let containerCreater = PersistentContainerCreater()
        let container = try? containerCreater.persistentContainer()
        return container
    }()

    // MARK: - UISceneSession Lifecycle

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }

    func application(
        _: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
