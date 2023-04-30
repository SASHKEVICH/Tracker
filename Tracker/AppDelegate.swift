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
    enum PersistentContainerError: Error {
        case cannotLoadPersistentContainer
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func getPersistentContainer() throws -> NSPersistentContainer {
        let containerCreater = PersistentContainerCreater()
        do {
            let container = try containerCreater.persistentContainer()
            return container
        } catch {
            throw PersistentContainerError.cannotLoadPersistentContainer
        }
    }
}
