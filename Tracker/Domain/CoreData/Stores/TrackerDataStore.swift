//
//  TrackerDataStore.swift
//  Tracker
//
//  Created by Александр Бекренев on 29.04.2023.
//

import Foundation
import CoreData

final class TrackerDataStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext, container: NSPersistentContainer) {
        self.container = container
        self.context = context
    }
    
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}

extension TrackerDataStore {
    func add(tracker: TrackerCoreData, for category: TrackerCategoryCoreData) throws {
        
    }
}
