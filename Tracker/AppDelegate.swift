//
//  AppDelegate.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.03.2023.
//

import UIKit
import CoreData

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        true
    }

    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    private lazy var persistentContainer: NSPersistentContainer? = {
        let containerCreater = PersistentContainerCreater()
        let container = try? containerCreater.persistentContainer()
        return container
    }()
    
    lazy var trackerDataStore: TrackersDataStore? = {
        guard let container = self.persistentContainer else { return nil }
        let trackerDataStore = TrackersDataStore(context: container.viewContext)
        return trackerDataStore
    }()
    
    lazy var trackerCategoryDataStore: TrackersCategoryDataStore? = {
        guard let container = self.persistentContainer else { return nil }
        let trackerCategoryDataStore = TrackersCategoryDataStore(context: container.viewContext)
        return trackerCategoryDataStore
    }()
    
    lazy var trackerRecordDataStore: TrackersRecordDataStore? = {
        guard let container = self.persistentContainer else { return nil }
        let trackerRecordDataStore = TrackersRecordDataStore(context: container.viewContext)
        return trackerRecordDataStore
    }()
}
